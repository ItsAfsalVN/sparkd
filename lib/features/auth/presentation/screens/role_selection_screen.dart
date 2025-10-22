import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/login_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/sign_up_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final logo = isLightMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(logo, width: 105, height: 35, fit: BoxFit.contain),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    // Spark Section
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignUpScreen(userType: UserType.spark),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary100,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 0,
                              color: context.colors.textPrimary.withValues(
                                alpha: .5,
                              ),
                            ),
                            BoxShadow(
                              offset: Offset(0, -1),
                              blurRadius: 2,
                              spreadRadius: 0,
                              color: context.colors.background.withValues(
                                alpha: .5,
                              ),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                'Offer My Skills',
                                style: Theme.of(context).textStyles.heading3
                                    .copyWith(color: AppColors.black),
                              ),
                              Text(
                                'Share your digital skills with local businesses, build a portfolio that matters, and work flexibly.',
                                style: Theme.of(context).textStyles.paragraph
                                    .copyWith(color: AppColors.black700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // SME Section
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignUpScreen(userType: UserType.sme),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary400,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 0,
                              color: context.colors.textPrimary.withValues(
                                alpha: .5,
                              ),
                            ),
                            BoxShadow(
                              offset: Offset(0, -1),
                              blurRadius: 2,
                              spreadRadius: 0,
                              color: context.colors.background.withValues(
                                alpha: .5,
                              ),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                'Grow My Business',
                                style: Theme.of(context).textStyles.heading3
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                'Find skilled young creators from your own neighbourhood. Browse and buy simple, fixed-price services to help your business shine online.',
                                style: Theme.of(context).textStyles.paragraph
                                    .copyWith(color: AppColors.white100),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
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
    );
  }
}
