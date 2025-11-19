import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/password_reset_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  late final ForgotPasswordBloc _forgotPasswordBloc;
  bool _emailTouched = false;
  bool _hasEmail = false;

  @override
  void initState() {
    super.initState();
    _forgotPasswordBloc = di.sl<ForgotPasswordBloc>();

    // Track email content for button state
    _emailController.addListener(() {
      setState(() {
        _hasEmail = _emailController.text.trim().isNotEmpty;
      });
    });

    // Mark email as touched when it loses focus
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && !_emailTouched) {
        setState(() {
          _emailTouched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _forgotPasswordBloc.close();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    // Mark field as touched when user types
    if (!_emailTouched) {
      setState(() {
        _emailTouched = true;
      });
    }
    _forgotPasswordBloc.add(ForgotPasswordEmailChanged(value));
  }

  void _submitForm() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showSnackbar(
        context,
        'Please enter your email address',
        SnackBarType.error,
      );
      return;
    }

    if (!email.contains('@')) {
      showSnackbar(
        context,
        'Please enter a valid email address',
        SnackBarType.error,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _forgotPasswordBloc.add(const ForgotPasswordSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final logo = isLightMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';
    final textStyles = Theme.of(context).textStyles;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _forgotPasswordBloc,
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            // Navigate to confirmation screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PasswordResetSentScreen(email: state.email),
              ),
            );
            logger.i("ForgotPassword: Reset email sent to ${state.email}");
          } else if (state.status == FormStatus.failure &&
              state.errorMessage != null) {
            // Show error message
            showSnackbar(context, state.errorMessage!, SnackBarType.error);
            logger.e("ForgotPassword: Failed - ${state.errorMessage}");
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_rounded),
            ),
            title: Image.asset(
              logo,
              height: 35,
              width: 105,
              fit: BoxFit.contain,
            ),
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 32,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              "Reset your\nPassword",
                              style: Theme.of(context).textStyles.heading2,
                            ),
                            Text(
                              "Enter the email address associated with your account, and we'll send you a link to reset your password.",
                              style: textStyles.subtext.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: .5,
                                ),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                          builder: (context, state) {
                            return CustomTextField(
                              hintText: "Enter your email",
                              labelText: "Email",
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: _onEmailChanged,
                              validator: (value) {
                                // Show validation errors after user has interacted with the field
                                if (!_emailTouched) return null;

                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.trim().contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        final isLoading = state.status == FormStatus.submitting;

                        return CustomButton(
                          onPressed: _hasEmail && !isLoading
                              ? _submitForm
                              : null,
                          title: isLoading ? "Sending..." : "Send Reset Link",
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
}
