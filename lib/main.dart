import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/decision_screen.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_styles.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'core/services/service_locator.dart' as di;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  FirebaseOptions? options;

  if (kIsWeb) {
    options = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_WEB_API_KEY']!,
      appId: dotenv.env['FIREBASE_WEB_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID']!,
      authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN']!,
      storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET']!,
      measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID']!,
    );
  } else if (Platform.isMacOS || Platform.isIOS) {
    options = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_IOS_API_KEY']!,
      appId: dotenv.env['FIREBASE_IOS_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_IOS_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_IOS_STORAGE_BUCKET']!,
      iosBundleId: dotenv.env['FIREBASE_IOS_IOS_BUNDLED']!,
    );
  } else if (Platform.isAndroid) {
    options = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY']!,
      appId: dotenv.env['FIREBASE_ANDROID_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_ANDROID_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET']!,
    );
  } else if (Platform.isWindows) {
    options = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_WINDOWS_API_KEY']!,
      appId: dotenv.env['FIREBASE_WINDOWS_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_WINDOWS_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_WINDOWS_PROJECT_ID']!,
      authDomain: dotenv.env['FIREBASE_WINDOWS_AUTH_DOMAIN']!,
      storageBucket: dotenv.env['FIREBASE_WINDOWS_STORAGE_BUCKET']!,
      measurementId: dotenv.env['FIREBASE_WINDOWS_MEASUREMENT_ID'],
    );
  } else {
    throw UnsupportedError(
      'Firebase initialization is not supported on this platform',
    );
  }

  await Firebase.initializeApp(options: options);

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
