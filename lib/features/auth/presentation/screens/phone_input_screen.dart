import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/phone/phone_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/input_otp_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:sparkd/core/utils/form_statuses.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final _phoneNumberNode = FocusNode();
  late final PhoneBloc _phoneBloc;
  bool _hasNavigated = false;

  UserType? _userType;

  @override
  void initState() {
    super.initState();
    _phoneBloc = di.sl<PhoneBloc>();

    final SignUpDataRepository signUpDataRepository =
        _phoneBloc.signUpDataRepository;
    final savedData = signUpDataRepository.getData();

    _userType = savedData.userType;

    _phoneNumberController.text = _phoneBloc.state.phoneNumber;

    logger.i(
      "PhoneInputScreen: Pre-filled phone number from repository: ${_phoneBloc.state.phoneNumber}",
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneNumberNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final logo = isLight
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';
    final textStyle = Theme.of(context).textStyles;

    // Ensure userType is safe before passing
    final UserType safeUserType = _userType ?? UserType.spark;

    return BlocProvider.value(
      value: _phoneBloc,
      child: BlocListener<PhoneBloc, PhoneState>(
        listener: (context, state) {
          if (state.status == FormStatus.otpSent && !_hasNavigated) {
            _hasNavigated = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: _phoneBloc,
                    child: InputOtpScreen(
                      phoneNumber: state.phoneNumber,
                      verificationID: state.verificationId!,
                    ),
                  ),
                ),
              );
            });
          } else if (state.status == FormStatus.failure) {
            showSnackbar(
              context,
              state.errorMessage ?? 'Failed to send OTP',
              SnackBarType.error,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(userType: safeUserType),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back_rounded),
            ),
            title: Image.asset(
              logo,
              width: 105,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      spacing: 36,
                      children: [
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verify Your \nMobile Number",
                              style: textStyle.heading2.copyWith(height: 1.2),
                            ),
                            Text(
                              "We need to verify your number to help keep your account secure and our community authentic.",
                              style: textStyle.paragraph.copyWith(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: .7),
                              ),
                            ),
                          ],
                        ),
                        BlocBuilder<PhoneBloc, PhoneState>(
                          buildWhen: (previous, current) =>
                              previous.isPhoneNumberValid !=
                              current.isPhoneNumberValid,
                          builder: (context, state) {
                            return CustomTextField(
                              hintText: 'Enter phone number',
                              labelText: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              controller: _phoneNumberController,
                              focusNode: _phoneNumberNode,
                              textInputAction: TextInputAction.done,
                              autoFocus: _phoneNumberController
                                  .text
                                  .isEmpty, // Only autofocus if field is empty
                              onFieldSubmitted: (value) {
                                if (!_hasNavigated) {
                                  _submitPhone(context);
                                }
                              },
                              onChanged: (value) {
                                _phoneBloc.add(
                                  PhoneNumberChanged(phoneNumber: value),
                                );
                              },
                              validator: (_) {
                                return !state.isPhoneNumberValid &&
                                        state.phoneNumber.isNotEmpty
                                    ? 'Enter a 10 digit valid phone number'
                                    : null;
                              },
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '+91',
                                      style: Theme.of(context)
                                          .textStyles
                                          .subtext
                                          .copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    BlocBuilder<PhoneBloc, PhoneState>(
                      buildWhen: (prev, curr) => prev.status != curr.status,
                      builder: (context, state) {
                        final isLoading = state.status == FormStatus.submitting;

                        return CustomButton(
                          onPressed:
                              state.isPhoneNumberValid &&
                                  !_hasNavigated &&
                                  !isLoading
                              ? () => _submitPhone(context)
                              : null,
                          title: isLoading ? "Sending..." : "Next",
                          isLoading: isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitPhone(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      _phoneBloc.add(PhoneNumberSubmitted());
    } else {
      logger.e("PhoneInputScreen: Validation failed.");
    }
  }
}
