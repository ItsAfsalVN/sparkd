import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/presentation/widgets/divider.dart';
import 'package:sparkd/core/presentation/widgets/google_sign_in_button.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/login_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:sparkd/core/utils/form_statuses.dart';

class SignUpScreen extends StatefulWidget {
  final UserType userType;
  const SignUpScreen({super.key, required this.userType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Focus Nodes
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // Form Key & Controllers
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // BLoC Instance created in initState
  late final SignUpBloc _signUpBloc;

  @override
  void initState() {
    super.initState();
    _signUpBloc = SignUpBloc(signUpDataRepository: di.sl());

    final savedData = _signUpBloc.state;

    _fullNameController.text = savedData.fullName;
    _emailController.text = savedData.email;
    _passwordController.text = savedData.password;
    _confirmPasswordController.text = savedData.confirmPassword;

    logger.i("SignUpScreen: Pre-filled form fields from repository.");

    // Trigger validation for all pre-filled fields
    if (_fullNameController.text.isNotEmpty) {
      _signUpBloc.add(SignUpFullNameChanged(_fullNameController.text));
    }

    if (_emailController.text.isNotEmpty) {
      _signUpBloc.add(SignUpEmailChanged(_emailController.text));
    }

    if (_passwordController.text.isNotEmpty) {
      _signUpBloc.add(SignUpPasswordChanged(_passwordController.text));
    }

    if (_confirmPasswordController.text.isNotEmpty) {
      _signUpBloc.add(
        SignUpConfirmPasswordChanged(_confirmPasswordController.text),
      );
    }
  }

  @override
  void dispose() {
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final textStyles = Theme.of(context).textStyles;

    return BlocProvider.value(
      value: _signUpBloc,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  spacing: 20,
                  children: [
                    // --- Header Row ---
                    Row(
                      spacing: 2,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoleSelectionScreen(),
                              ),
                            );
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
                    Text("Let's Get You Started", style: textStyles.heading1),

                    // --- Form Fields Builder ---
                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        return Column(
                          spacing: 16,
                          children: [
                            CustomTextField(
                              autoFocus: true,
                              hintText: 'Enter you full name',
                              labelText: 'Full Name',
                              controller: _fullNameController,
                              focusNode: _fullNameFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) => FocusScope.of(
                                context,
                              ).requestFocus(_emailFocusNode),
                              onChanged: (value) => context
                                  .read<SignUpBloc>()
                                  .add(SignUpFullNameChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Don't show error for empty field
                                }
                                if (value.isNotEmpty && value.length < 2) {
                                  return 'Name cannot be empty';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Enter valid email',
                              labelText: 'Email',
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) => FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocusNode),
                              onChanged: (value) => context
                                  .read<SignUpBloc>()
                                  .add(SignUpEmailChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Don't show error for empty field
                                }
                                final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Enter the password',
                              labelText: 'Password',
                              obscureText: true,
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) => FocusScope.of(
                                context,
                              ).requestFocus(_confirmPasswordFocusNode),
                              onChanged: (value) => context
                                  .read<SignUpBloc>()
                                  .add(SignUpPasswordChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Don't show error for empty field
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Confirm password',
                              labelText: 'Confirm Password',
                              obscureText: true,
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submitForm(context),
                              onChanged: (value) => context
                                  .read<SignUpBloc>()
                                  .add(SignUpConfirmPasswordChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Don't show error for empty field
                                }
                                final password = _passwordController.text;
                                if (password.isNotEmpty && value != password) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    // --- Submission Button & Listener ---
                    BlocListener<SignUpBloc, SignUpState>(
                      listenWhen: (prev, curr) => prev.status != curr.status,
                      listener: (context, state) {
                        if (state.status == FormStatus.detailsSubmitted) {
                          // 1. Notify AuthBloc (to save persistence step)
                          BlocProvider.of<AuthBloc>(
                            context,
                          ).add(AuthDetailsSubmitted());

                          // 2. Navigate immediately to Phone Input
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhoneInputScreen(),
                            ),
                          ).then((_) {
                            // 3. Reset state when user pops back from PhoneInputScreen
                            context.read<SignUpBloc>().add(SignUpStatusReset());
                          });
                        }
                      },
                      child: BlocBuilder<SignUpBloc, SignUpState>(
                        buildWhen: (prev, curr) => prev.status != curr.status,
                        builder: (context, state) {
                          if (state.status == FormStatus.submitting) {
                            return const CircularProgressIndicator();
                          }
                          return CustomButton(
                            onPressed: state.status == FormStatus.valid
                                ? () => _submitForm(context)
                                : null,
                            title: "Sign up",
                          );
                        },
                      ),
                    ),

                    // --- Bottom Widgets (Divider, Google Sign-in, Login Link) ---
                    Column(
                      spacing: 6,
                      children: [
                        const LabeledDivider(label: 'Or'),
                        GoogleSignInButton(),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      // Pass the userType from the Widget instance to the BLoC event
      BlocProvider.of<SignUpBloc>(
        context,
      ).add(SignUpSubmitted(widget.userType));
    } else {
      logger.e("Form validation failed");
    }
  }
}
