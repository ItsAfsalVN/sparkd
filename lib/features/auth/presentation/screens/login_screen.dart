import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/presentation/widgets/divider.dart';
import 'package:sparkd/core/presentation/widgets/google_sign_in_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/spark_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late final SignInBloc _signInBloc;
  bool _hasEmail = false;
  bool _hasPassword = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    _signInBloc = di.sl<SignInBloc>();

    _emailController.addListener(() {
      setState(() {
        _hasEmail = _emailController.text.trim().isNotEmpty;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _hasPassword = _passwordController.text.trim().isNotEmpty;
      });
    });

    // Mark fields as touched when they lose focus
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && !_emailTouched) {
        setState(() {
          _emailTouched = true;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus && !_passwordTouched) {
        setState(() {
          _passwordTouched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _signInBloc.close();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _emailTouched = true;
    });
    _signInBloc.add(SignInEmailChanged(value));
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordTouched = true;
    });
    _signInBloc.add(SignInPasswordChanged(value));
  }

  void _submitForm() {
    // Validate form fields based on current values
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _signInBloc.add(const SignInSubmitted());
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
      value: _signInBloc,
      child: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            // Login successful, navigate directly to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SparkDashboardScreen()),
            );
            logger.i("LoginScreen: Login successful, navigating to dashboard");
          } else if (state.status == FormStatus.failure &&
              state.errorMessage != null) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            logger.e("LoginScreen: Login failed - ${state.errorMessage}");
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  spacing: 80,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome\nBack!", style: textStyles.heading1),
                    Column(
                      spacing: 20,
                      children: [
                        GoogleSignInButton(),
                        LabeledDivider(label: 'Or'),
                        BlocBuilder<SignInBloc, SignInState>(
                          builder: (context, state) {
                            return CustomTextField(
                              labelText: "Email",
                              hintText: "Enter valid email",
                              autoFocus: true,
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (value) => {
                                _passwordFocusNode.requestFocus(),
                              },
                              onChanged: _onEmailChanged,
                              validator: (value) {
                                // Only show validation errors if the user has interacted with this field
                                if (!_emailTouched) return null;

                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        BlocBuilder<SignInBloc, SignInState>(
                          builder: (context, state) {
                            return CustomTextField(
                              labelText: "Password",
                              hintText: "Enter the password",
                              obscureText: true,
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              keyboardType: TextInputType.visiblePassword,
                              onFieldSubmitted: (value) => {
                                _passwordFocusNode.unfocus(),
                              },
                              onChanged: _onPasswordChanged,
                              validator: (value) {
                                // Only show validation errors if the user has interacted with this field
                                if (!_passwordTouched) return null;

                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen(),
                                ),
                              ),
                            },
                            child: Text(
                              "Forgot Password?",
                              style: textStyles.subtext.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface.withValues(
                                  alpha: .5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 40,
                      children: [
                        BlocBuilder<SignInBloc, SignInState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == FormStatus.submitting;

                            return CustomButton(
                              onPressed: _hasEmail && _hasPassword && !isLoading
                                  ? _submitForm
                                  : null,
                              title: isLoading ? "Signing In..." : "Sign In",
                              isLoading: isLoading,
                            );
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: .8),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoleSelectionScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign up',
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
