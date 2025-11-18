import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/custom_text_field.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
      body: SafeArea(
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
                          color: colorScheme.onSurface.withValues(alpha: .5),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  CustomTextField(
                    hintText: "Enter your email",
                    labelText: "Email",
                  ),
                ],
              ),
              CustomButton(onPressed: () {}, title: "Send Reset Link"),
            ],
          ),
        ),
      ),
    );
  }
}
