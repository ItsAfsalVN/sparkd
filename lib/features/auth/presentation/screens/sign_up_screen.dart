import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/presentation/widgets/divider.dart';
import 'package:sparkd/core/presentation/widgets/google_sign_in_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
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
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final SignUpBloc _signUpBloc;
  late final SignInBloc _signInBloc;

  @override
  void initState() {
    super.initState();
    _signUpBloc = SignUpBloc(signUpDataRepository: di.sl());
    _signInBloc = di.sl<SignInBloc>();

    // Save userType immediately when screen is created
    final signUpDataRepo = di.sl<SignUpDataRepository>();
    final currentData = signUpDataRepo.getData();
    signUpDataRepo.updateData(currentData.copyWith(userType: widget.userType));
    logger.i(
      "SignUpScreen: Saved userType '${widget.userType}' to repository on screen initialization",
    );

    // Verify the save
    final verifyData = signUpDataRepo.getData();
    logger.i(
      "SignUpScreen: VERIFICATION - UserType after initialization save: ${verifyData.userType}",
    );

    final savedData = _signUpBloc.state;

    _fullNameController.text = savedData.fullName;
    _emailController.text = savedData.email;
    _passwordController.text = savedData.password;
    _confirmPasswordController.text = savedData.confirmPassword;

    logger.i("SignUpScreen: Pre-filled form fields from repository.");

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
    _signUpBloc.close();
    _signInBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final textStyles = Theme.of(context).textStyles;
    final String logo = isLight
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _signUpBloc),
        BlocProvider.value(value: _signInBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
              );
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
          title: Image.asset(logo, height: 35, width: 105, fit: BoxFit.contain),
        ),
        body: BlocListener<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state.status == FormStatus.success) {
              // Google Sign-In successful, save userType and email to continue with sign-up flow
              final signUpDataRepo = di.sl<SignUpDataRepository>();
              final currentData = signUpDataRepo.getData();

              // Get the user's email from Firebase
              final currentUser = di.sl<FirebaseAuth>().currentUser;
              final userEmail = currentUser?.email ?? currentData.email;
              final userName = currentUser?.displayName ?? currentData.fullName;

              signUpDataRepo.updateData(
                currentData.copyWith(
                  userType: widget.userType,
                  email: userEmail,
                  fullName: userName,
                ),
              );
              logger.i(
                "SignUpScreen: Saved userType '${widget.userType}' and email '$userEmail' after Google Sign-In",
              );

              // Verify the save
              final verifyData = signUpDataRepo.getData();
              logger.i(
                "SignUpScreen: VERIFICATION - UserType after Google Sign-In save: ${verifyData.userType}",
              );

              BlocProvider.of<AuthBloc>(context).add(AuthDetailsSubmitted());

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhoneInputScreen(),
                ),
              );
              logger.i(
                "SignUpScreen: Google Sign-In successful, continuing to phone input",
              );
            } else if (state.status == FormStatus.failure &&
                state.errorMessage != null) {
              // Show error message
              showSnackbar(context, state.errorMessage!, SnackBarType.error);
              logger.e(
                "SignUpScreen: Google Sign-In failed - ${state.errorMessage}",
              );
            }
          },
          child: BlocBuilder<SignInBloc, SignInState>(
            builder: (context, signInState) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            spacing: 20,
                            children: [
                              Text(
                                "Let's Get You Started",
                                style: textStyles.heading1,
                              ),

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
                                        onFieldSubmitted: (value) =>
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(_emailFocusNode),
                                        onChanged: (value) => context
                                            .read<SignUpBloc>()
                                            .add(SignUpFullNameChanged(value)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return null;
                                          }
                                          if (value.isNotEmpty &&
                                              value.length < 2) {
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
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (value) =>
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(_passwordFocusNode),
                                        onChanged: (value) => context
                                            .read<SignUpBloc>()
                                            .add(SignUpEmailChanged(value)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return null;
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
                                        onFieldSubmitted: (value) =>
                                            FocusScope.of(context).requestFocus(
                                              _confirmPasswordFocusNode,
                                            ),
                                        onChanged: (value) => context
                                            .read<SignUpBloc>()
                                            .add(SignUpPasswordChanged(value)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return null;
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
                                        onFieldSubmitted: (_) =>
                                            _submitForm(context),
                                        onChanged: (value) =>
                                            context.read<SignUpBloc>().add(
                                              SignUpConfirmPasswordChanged(
                                                value,
                                              ),
                                            ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return null;
                                          }
                                          final password =
                                              _passwordController.text;
                                          if (password.isNotEmpty &&
                                              value != password) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),

                              BlocListener<SignUpBloc, SignUpState>(
                                listenWhen: (prev, curr) =>
                                    prev.status != curr.status,
                                listener: (context, state) {
                                  if (state.status ==
                                      FormStatus.detailsSubmitted) {
                                    BlocProvider.of<AuthBloc>(
                                      context,
                                    ).add(AuthDetailsSubmitted());

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PhoneInputScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: BlocBuilder<SignUpBloc, SignUpState>(
                                  buildWhen: (prev, curr) =>
                                      prev.status != curr.status,
                                  builder: (context, state) {
                                    final isLoading =
                                        state.status == FormStatus.submitting;

                                    return CustomButton(
                                      onPressed:
                                          state.status == FormStatus.valid &&
                                              !isLoading
                                          ? () => _submitForm(context)
                                          : null,
                                      title: isLoading
                                          ? "Signing Up..."
                                          : "Sign up",
                                      isLoading: isLoading,
                                    );
                                  },
                                ),
                              ),

                              Column(
                                spacing: 6,
                                children: [
                                  const LabeledDivider(label: 'Or'),
                                  GoogleSignInButton(isSignUp: true),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: .8),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      ),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
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
                  // Loading overlay for Google Sign-In
                  if (signInState.status == FormStatus.loading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Signing in with Google...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      BlocProvider.of<SignUpBloc>(
        context,
      ).add(SignUpSubmitted(widget.userType));
    } else {
      logger.e("Form validation failed");
    }
  }
}
