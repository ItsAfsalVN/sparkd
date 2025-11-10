import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/otp_input.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/phone/phone_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/auth/presentation/screens/sme/add_business_details_screen.dart';
import 'package:sparkd/features/spark/presentation/screens/add_skills_screen.dart';

class InputOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationID;
  const InputOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationID,
  });

  @override
  State<InputOtpScreen> createState() => _InputOtpScreenState();
}

class _InputOtpScreenState extends State<InputOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _hasNavigated = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final textStyle = Theme.of(context).textStyles;
    final logo = isLight
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (!_hasNavigated) {
              BlocProvider.of<PhoneBloc>(context).add(OtpSessionCancelled());
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
        title: Image.asset(logo, width: 105, height: 35, fit: BoxFit.contain),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: BlocListener<PhoneBloc, PhoneState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormStatus.success && !_hasNavigated) {
                _hasNavigated = true;

                // OTP Verified successfully!
                logger.i(
                  "OTP Verified! Triggering final sign up/login in AuthBloc...",
                );

                BlocProvider.of<AuthBloc>(
                  context,
                ).add(AuthPhoneNumberVerified());
                logger.i("Notified AuthBloc: AuthPhoneVerified.");

                final phoneBloc = context.read<PhoneBloc>();
                final signUpDataRepo = phoneBloc.signUpDataRepository;
                final signUpData = signUpDataRepo.getData();
                final userType = signUpData.userType;

                logger.d("Retrieved SignUpData: $signUpData");
                logger.i("UserType for navigation: $userType");

                // Navigate after frame is complete
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;

                  showSnackbar(
                    context,
                    "Phone Number Verified Successfully!",
                    SnackBarType.success,
                  );

                  if (userType == UserType.spark) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AddSkillsScreen(),
                      ),
                    );
                  } else if (userType == UserType.sme) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AddBusinessDetailsScreen(),
                      ),
                    );
                  } else {
                    logger.e("Unimplemented usertype : $userType");
                  }
                });
              } else if (state.status == FormStatus.failure &&
                  state.errorMessage != null) {
                showSnackbar(context, state.errorMessage!, SnackBarType.error);
                _otpController.clear();
                context.read<PhoneBloc>().add(
                  const OtpCodeChanged(smsCode: ''),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 36,
                  children: [
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enter \nVerification Code",
                          style: textStyle.heading2,
                        ),
                        RichText(
                          text: TextSpan(
                            style: textStyle.paragraph.copyWith(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .7),
                            ),
                            children: [
                              const TextSpan(
                                text: "We've sent a 6-digit code to ",
                              ),
                              TextSpan(
                                text: "+91 ${widget.phoneNumber}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ". Please enter it below."),
                            ],
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<PhoneBloc, PhoneState>(
                      buildWhen: (prev, curr) =>
                          prev.status != curr.status ||
                          prev.smsCode != curr.smsCode,
                      builder: (context, state) {
                        return OtpInput(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          autoFocus: true,
                          onChanged: (pin) {
                            context.read<PhoneBloc>().add(
                              OtpCodeChanged(smsCode: pin),
                            );
                          },
                          onCompleted: (pin) {
                            logger.i("OTP Entered: $pin");
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                if (mounted && !_hasNavigated) {
                                  _submitOtp();
                                }
                              },
                            );
                          },
                          validator: (pin) {
                            if (state.status == FormStatus.failure &&
                                state.errorMessage != null) {
                              return state.errorMessage;
                            }
                            return null;
                          },
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
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitOtp() {
    final phoneBloc = context.read<PhoneBloc>();
    final currentSmsCode = phoneBloc.state.smsCode;

    logger.i(
      "Inside _submitOtp. Current smsCode from state: '$currentSmsCode', Length: ${currentSmsCode.length}",
    );

    if (currentSmsCode.length == 6) {
      FocusScope.of(context).unfocus();
      phoneBloc.add(const OtpSubmitted());
    } else {
      logger.e(
        "Submit called with incorrect code length: ${currentSmsCode.length}",
      );
      showSnackbar(
        context,
        "Please ensure 6 digits are entered.",
        SnackBarType.error,
      );
    }
  }
}
