import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/role_selection_screen.dart';
// Import PhoneInputScreen
import 'package:sparkd/features/auth/presentation/screens/phone_input_screen.dart';
// Import logger if you use it
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/presentation/screens/sme/add_business_details_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/spark/add_skills_screen.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        logger.i(
          "DecisionScreen received AuthBloc state: ${state.runtimeType}",
        ); // Add logging

        if (state is AuthAuthenticated) {
          logger.i("Navigating based on role: ${state.userType}");
          switch (state.userType) {
            case UserType.spark:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SparkDashboard()));
              break;
            case UserType.sme:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SmeDashboard()));
              break;
            case UserType.admin:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
              break;
          }
        } else if (state is AuthUnauthenticated) {
          logger.i("Navigating to RoleSelectionScreen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            ),
          );
        } else if (state is AuthFirstRun) {
          logger.i("Navigating to OnboardingScreen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else if (state is AuthAwaitingPhoneNumber) {
          logger.i("Navigating to PhoneInputScreen (Resuming sign-up)");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhoneInputScreen()),
          );
        } else if (state is AuthAwaitingBusinessDetails) {
          logger.i("Navigating to AddBusinessDetailsScreen (Resuming sign-up)");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddBusinessDetailsScreen()),
          );
        } else if (state is AuthAwaitingSkills) {
          logger.i("Navigating to AddSkillsScreen (Resuming sign-up)");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddSkillsScreen()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
