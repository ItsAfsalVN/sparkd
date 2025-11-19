import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/screens/login_screen.dart';

class PasswordResetSentScreen extends StatelessWidget {
  final String email;

  const PasswordResetSentScreen({super.key, required this.email});

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
        title: Image.asset(logo, height: 35, width: 105, fit: BoxFit.contain),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Content Section
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    Text(
                      "Check Your Inbox!",
                      style: textStyles.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      "We've sent a password reset link to:",
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Email
                    Text(
                      email,
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      "If you don't see it in a few minutes, please check your spam folder.",
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Actions Section
              Column(
                spacing: 8,
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    title: "Back to Login",
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Try Different Email',
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
