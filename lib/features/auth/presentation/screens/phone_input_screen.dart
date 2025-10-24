import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/bloc/phone/phone_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';

class PhoneInputScreen extends StatefulWidget {
  final UserType userType;
  const PhoneInputScreen({super.key, required this.userType});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final _phoneNumberNode = FocusNode();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneNumberNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final textStyle = Theme.of(context).textStyles;
    return BlocProvider(
      create: (context) => di.sl<PhoneBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                      Row(
                        spacing: 2,
                        children: [
                          IconButton(
                            onPressed: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) Navigator.pop(context);
                              });
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 24,
                              color: AppColors.black400,
                            ),
                          ),
                          Image.asset(
                            isLight
                                ? 'assets/images/logo_light.png'
                                : 'assets/images/logo_dark.png',
                            width: 105,
                            height: 35,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
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
                            onFieldSubmitted: (value) {
                              _submitPhone(context);
                            },
                            onChanged: (value) {
                              context.read<PhoneBloc>().add(
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
                                    style: Theme.of(context).textStyles.subtext
                                        .copyWith(fontWeight: FontWeight.w900),
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
                      if (state.status == FormStatus.submitting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return CustomButton(
                        onPressed: state.isPhoneNumberValid
                            ? () => _submitPhone(context)
                            : null,
                        title: 'Next',
                      );
                    },
                  ),
                ],
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
      BlocProvider.of<PhoneBloc>(context).add(PhoneNumberSubmitted());
    } else {
      print("PhoneInputScreen: Validation failed.");
    }
  }
}
