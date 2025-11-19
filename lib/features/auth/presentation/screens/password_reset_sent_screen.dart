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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 60,
                        color: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      "Check Your Email",
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
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Email
                    Text(
                      email,
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Additional Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Check your email and click on the password reset link to create a new password.",
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Can't find the email? Check your spam folder.",
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions Section
              Column(
                spacing: 16,
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
