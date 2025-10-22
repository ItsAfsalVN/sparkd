import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/presentation/widgets/divider.dart';
import 'package:sparkd/core/presentation/widgets/google_sign_in_button.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/login_screen.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/screens/phone_input_screen.dart';

class SignUpScreen extends StatefulWidget {
  final UserType userType;
  const SignUpScreen({super.key, required this.userType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

    return BlocProvider(
      create: (context) =>
          SignUpBloc(signUpDataRepository: di.sl<SignUpDataRepository>()),
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
                    Row(
                      spacing: 2,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
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
                    Text(
                      "Let's Get You Started",
                      style: Theme.of(context).textStyles.heading1,
                    ),

                    BlocBuilder<SignUpBloc, SignUpState>(
                      builder: (context, state) {
                        return Column(
                          spacing: 16,
                          children: [
                            CustomTextField(
                              hintText: 'Enter you full name',
                              labelText: 'Full Name',
                              controller: _fullNameController,
                              focusNode: _fullNameFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (value) => FocusScope.of(
                                context,
                              ).requestFocus(_emailFocusNode),
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                  SignUpFullNameChanged(value),
                                );
                              },
                              validator: (_) {
                                return !state.isFullNameValid &&
                                        state.fullName.isNotEmpty
                                    ? 'Name cannot be empty'
                                    : null;
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
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                  SignUpEmailChanged(value),
                                );
                              },
                              validator: (_) {
                                return !state.isEmailValid &&
                                        state.email.isNotEmpty
                                    ? 'Please enter a valid email'
                                    : null;
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
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                  SignUpPasswordChanged(value),
                                );
                              },
                              validator: (_) {
                                return !state.isPasswordValid &&
                                        state.password.isNotEmpty
                                    ? 'Password must be at least 6 characters'
                                    : null;
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
                              onChanged: (value) {
                                context.read<SignUpBloc>().add(
                                  SignUpConfirmPasswordChanged(value),
                                );
                              },
                              validator: (_) {
                                return !state.doPasswordsMatch &&
                                        state.confirmPassword.isNotEmpty
                                    ? 'Passwords do not match'
                                    : null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    BlocListener<SignUpBloc, SignUpState>(
                      listenWhen: (prev, curr) => prev.status != curr.status,
                      listener: (context, state) {
                        if (state.status == FormStatus.step1Completed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PhoneInputScreen(userType: widget.userType),
                            ),
                          ).then((_) {
                            // Reset status when coming back
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
      BlocProvider.of<SignUpBloc>(context).add(SignUpSubmitted());
    } else {
      print("Form validation failed");
    }
  }
}
