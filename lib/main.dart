import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/decision_screen.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_styles.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'core/services/service_locator.dart' as di;
import 'core/utils/logger.dart';

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
    try {
      await dotenv.load(fileName: '.env');

      // 1. Initialize Firebase with timeout to prevent hanging
      logger.i('=== Starting Firebase initialization ===');
      try {
        await Firebase.initializeApp(
          options: _firebaseOptionsFromEnv(),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException(
              'Firebase initialization timed out after 30 seconds. '
              'Check your network connection and Firebase credentials.',
            );
          },
        );
        logger.i('=== Firebase initialized successfully ===');
      } catch (e) {
        logger.e('Firebase initialization error: $e');
        rethrow;
      }

      // 2. Configure Firestore with timeout and connection settings
      logger.i('=== Configuring Firestore ===');
      _configureFirestore();
      logger.i('=== Firestore configured successfully ===');

      // 3. Initialize your service locator (dependency injection)
      logger.i('=== Starting service locator initialization ===');
      await di.init().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Service locator initialization timed out.');
        },
      );
      logger.i('=== Service locator initialized successfully ===');

      // 4. Initialize notification service
      final notificationService = di.sl<NotificationService>();
      await notificationService.initialize();

      // 5. Listen to foreground messages
      notificationService.listenToForegroundMessages((message) {
        // Handle foreground notifications
        // You can show a custom in-app notification here
        logger.i('Foreground notification: ${message.notification?.title}');
      });

      // 6. Handle notification taps when app is in background
      notificationService.handleBackgroundNotificationTap((message) {
        // Navigate to relevant screen based on notification data
        logger.i('App opened from notification: ${message.data}');
      });

      logger.i('=== App initialization complete ===');
    } catch (e) {
      logger.e('App initialization failed: $e', error: e);
      rethrow;
    }
  }

  /// Configures Firestore with appropriate timeout and connection settings
  void _configureFirestore() {
    try {
      final firestore = FirebaseFirestore.instance;

      // Configure Firestore settings for better network handling
      firestore.settings = const Settings(
        // Set persistence enabled for offline support
        persistenceEnabled: true,

        // Set cache size (100 MB - recommended for most apps)
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,

        // Note: Host and SSL settings can be configured for custom emulator
        // host: 'localhost:8080',
        // sslEnabled: false,
      );

      logger.i('Firestore settings configured successfully');
    } catch (e) {
      logger.e('Error configuring Firestore: $e');
      // Don't rethrow - Firestore should still work with default settings
    }
  }

  FirebaseOptions _firebaseOptionsFromEnv() {
    String env(String key) {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        throw Exception('Missing required env value: $key');
      }
      return value;
    }

    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: env('FIREBASE_WEB_API_KEY'),
        appId: env('FIREBASE_WEB_APP_ID'),
        messagingSenderId: env('FIREBASE_WEB_MESSAGING_SENDER_ID'),
        projectId: env('FIREBASE_WEB_PROJECT_ID'),
        authDomain: env('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: env('FIREBASE_WEB_STORAGE_BUCKET'),
        measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'],
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: env('FIREBASE_ANDROID_API_KEY'),
          appId: env('FIREBASE_ANDROID_APP_ID'),
          messagingSenderId: env('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
          projectId: env('FIREBASE_ANDROID_PROJECT_ID'),
          storageBucket: env('FIREBASE_ANDROID_STORAGE_BUCKET'),
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: env('FIREBASE_IOS_API_KEY'),
          appId: env('FIREBASE_IOS_APP_ID'),
          messagingSenderId: env('FIREBASE_IOS_MESSAGING_SENDER_ID'),
          projectId: env('FIREBASE_IOS_PROJECT_ID'),
          storageBucket: env('FIREBASE_IOS_STORAGE_BUCKET'),
          iosBundleId: dotenv.env['FIREBASE_IOS_IOS_BUNDLED'],
        );
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: env('FIREBASE_IOS_API_KEY'),
          appId: env('FIREBASE_IOS_APP_ID'),
          messagingSenderId: env('FIREBASE_IOS_MESSAGING_SENDER_ID'),
          projectId: env('FIREBASE_IOS_PROJECT_ID'),
          storageBucket: env('FIREBASE_IOS_STORAGE_BUCKET'),
          iosBundleId: dotenv.env['FIREBASE_IOS_IOS_BUNDLED'],
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return FirebaseOptions(
          apiKey: env('FIREBASE_WINDOWS_API_KEY'),
          appId: env('FIREBASE_WINDOWS_APP_ID'),
          messagingSenderId: env('FIREBASE_WINDOWS_MESSAGING_SENDER_ID'),
          projectId: env('FIREBASE_WINDOWS_PROJECT_ID'),
          authDomain: env('FIREBASE_WINDOWS_AUTH_DOMAIN'),
          storageBucket: env('FIREBASE_WINDOWS_STORAGE_BUCKET'),
          measurementId: dotenv.env['FIREBASE_WINDOWS_MEASUREMENT_ID'],
        );
      default:
        throw UnsupportedError('Unsupported platform for Firebase options');
    }
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
            home: Scaffold(
              backgroundColor: AppColors.white100,
              body: Center(
                child: Column(
                  spacing: 2,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.secondary500),
                    Text(
                      'Initializing...',
                      style: TextStyle(color: AppColors.secondary500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          logger.e('Initialization error: $error');

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to Initialize App',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error: $error\n\nTroubleshooting:\n• Check internet connection\n• Verify Firebase credentials in .env file\n• Ensure Firebase project is active',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Restart the app by recreating the widget
                          (context as Element).reassemble();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
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
