import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/presentation/widgets/divider.dart';
import 'package:sparkd/core/presentation/widgets/google_sign_in_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/role_selection_screen.dart';

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
  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final logo = isLightMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';
    final textStyles = Theme.of(context).textStyles;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        title: Image.asset(logo, height: 35, width: 105, fit: BoxFit.contain),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Welcome\nBack!", style: textStyles.heading1),
              Column(
                spacing: 16,
                children: [
                  GoogleSignInButton(),
                  LabeledDivider(label: 'Or'),
                ],
              ),
              Column(
                spacing: 16,
                children: [
                  CustomTextField(
                    labelText: "Email",
                    hintText: "Enter valid email",
                    autoFocus: true,
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (value) => {
                      _passwordFocusNode.requestFocus(),
                    },
                  ),
                  CustomTextField(
                    labelText: "Password",
                    hintText: "Enter the password",
                    obscureText: true,
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    keyboardType: TextInputType.visiblePassword,
                    onFieldSubmitted: (value) => {_passwordFocusNode.unfocus()},
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => {
                        Navigator.push(
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
                          color: colorScheme.onSurface.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CustomButton(onPressed: () {}, title: "Sign In"),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
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
                            builder: (context) => RoleSelectionScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
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
    );
  }
}
