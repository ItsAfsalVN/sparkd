import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Updated import name based on your code
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/decision_screen.dart';
import 'package:sparkd/core/utils/app_colors.dart';
// --- 1. IMPORT TEXT STYLE FILES ---
import 'package:sparkd/core/utils/app_text_styles.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'core/services/service_locator.dart' as di;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(
    BlocProvider(
      create: (context) {
        // Get the AuthBloc instance from the service locator
        return di.sl<AuthBloc>()..add(AuthCheckStatusRequested());
      },
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.white100,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.secondary400,
          onPrimary: AppColors.white,
          secondary: AppColors.primary100,
          onSecondary: AppColors.white700,
          tertiary: AppColors.accent300,
          onTertiary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.white700,
          error: Color(0xffFC3200),
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          headlineSmall: AppTextStyles.heading3,
          bodyLarge: AppTextStyles.paragraph,
          bodyMedium: AppTextStyles.subtext,
        ),
        extensions: const <ThemeExtension>[
          AppColorThemeExtension.light,
          AppTextThemeExtension.main,
        ],
      ),

      // Dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary100,
          onPrimary: AppColors.black,
          secondary: AppColors.secondary400,
          onSecondary: AppColors.white,
          tertiary: AppColors.accent300,
          onTertiary: AppColors.white,
          surface: AppColors.white700,
          onSurface: AppColors.black100,
          error: Color(0xffFC3200),
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          headlineSmall: AppTextStyles.heading3,
          bodyLarge: AppTextStyles.paragraph,
          bodyMedium: AppTextStyles.subtext,
        ),
        extensions: const <ThemeExtension>[
          AppColorThemeExtension.dark,
          AppTextThemeExtension.main,
        ],
      ),

      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecisionScreen();
  }
}
