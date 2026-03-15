import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/decision_screen.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_styles.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'core/services/service_locator.dart' as di;

void main(List<String> args) async {
  // Only keep the *absolutely essential* binding initialization here.
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app immediately. The app itself will handle initialization.
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // This Future will hold the state of our initialization.
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // Start the initialization process when this widget is first created.
    _initFuture = _initializeApp();
  }

  // This function now contains all the logic that was in main().
  Future<void> _initializeApp() async {
    // 1. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Initialize your service locator (dependency injection)
    await di.init();

    // 3. Initialize notification service
    final notificationService = di.sl<NotificationService>();
    await notificationService.initialize();

    // 4. Listen to foreground messages
    notificationService.listenToForegroundMessages((message) {
      // Handle foreground notifications
      // You can show a custom in-app notification here
      print('Foreground notification: ${message.notification?.title}');
    });

    // 5. Handle notification taps when app is in background
    notificationService.handleBackgroundNotificationTap((message) {
      // Navigate to relevant screen based on notification data
      print('App opened from notification: ${message.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to listen to the initialization future
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error initializing app: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return BlocProvider(
          create: (context) {
            return di.sl<AuthBloc>()..add(AuthCheckStatusRequested());
          },
          child: const MainAppContent(),
        );
      },
    );
  }
}

class MainAppContent extends StatelessWidget {
  const MainAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(backgroundColor: AppColors.white100),
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
          headlineMedium: AppTextStyles.heading3,
          headlineSmall: AppTextStyles.heading5,
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
        appBarTheme: AppBarTheme(backgroundColor: AppColors.black),
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
          headlineMedium: AppTextStyles.heading3,
          headlineSmall: AppTextStyles.heading4,
          titleLarge: AppTextStyles.heading5,
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
