import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'package:sparkd/core/services/permission_service.dart';
import 'package:sparkd/core/services/storage_service.dart';
import 'package:sparkd/features/auth/domain/usecases/create_user_with_email_and_password.dart';
import 'package:sparkd/features/auth/domain/usecases/forgot_password.dart';
import 'package:sparkd/features/auth/domain/usecases/get_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/logout.dart';
import 'package:sparkd/features/auth/domain/usecases/save_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:sparkd/features/gigs/domain/repositories/gig_repository.dart';
import 'package:sparkd/features/gigs/domain/usecases/create_new_gig.dart';
import 'package:sparkd/features/gigs/domain/usecases/get_gigs.dart';
import 'package:sparkd/features/gigs/domain/usecases/get_user_gigs.dart';
import 'package:sparkd/features/gigs/presentation/bloc/create_gig/create_gig_bloc.dart';
import 'package:sparkd/features/gigs/presentation/bloc/discover_gig/discover_gig_bloc.dart';
import 'package:sparkd/features/orders/data/datasources/order_remote_repository.dart';
import 'package:sparkd/features/orders/data/repositories/order_repository_implementation.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';
import 'package:sparkd/features/orders/domain/usecases/create_order_request.dart';
import 'package:sparkd/features/orders/presentation/bloc/order_bloc.dart';
import 'package:sparkd/features/spark/data/datasources/static_skill_data_source.dart';
import 'package:sparkd/features/gigs/data/datasources/gig_remote_data_source.dart';
import 'package:sparkd/features/gigs/data/repositories/gig_repository_impl.dart';
import 'package:sparkd/features/spark/presentation/bloc/skills_bloc.dart';
import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sparkd/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:sparkd/features/auth/data/repositories/sign_up_data_repository_implementation.dart';
import 'package:sparkd/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/domain/usecases/get_is_first_run.dart';
import 'package:sparkd/features/auth/domain/usecases/request_otp.dart';
import 'package:sparkd/features/auth/domain/usecases/set_onboarding_complete.dart';
import 'package:sparkd/features/auth/domain/usecases/verify_otp.dart';
import 'package:sparkd/features/auth/domain/usecases/login_user.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/phone/phone_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Auth Feature ---

  sl.registerLazySingleton(
    () => AuthBloc(
      getIsFirstRun: sl(),
      setOnboardingCompleted: sl(),
      localDataSource: sl(),
      signUpDataRepository: sl(),
      createUserWithEmailUseCase: sl(),
      saveUserProfileUseCase: sl(),
      getUserProfileUseCase: sl(),
      logoutUseCase: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerFactory(
    () => PhoneBloc(
      signUpDataRepository: sl(),
      requestOtpUseCase: sl(),
      verifyOtpUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SignInBloc(
      loginUserUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      getUserProfileUseCase: sl(),
    ),
  );

  sl.registerFactory(() => ForgotPasswordBloc(forgotPasswordUseCase: sl()));

  sl.registerFactory(
    () => SkillsBloc(signUpDataRepository: sl(), staticDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetIsFirstRun(sl()));
  sl.registerLazySingleton(() => SetOnboardingComplete(sl()));
  sl.registerLazySingleton(() => RequestOtpUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(
    () => CreateUserWithEmailUseCase(authRepository: sl()),
  );
  sl.registerLazySingleton(() => SaveUserProfileUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => LoginUserUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(repository: sl()));
  sl.registerLazySingleton(
    () => LogoutUseCase(authRepository: sl(), signUpDataRepository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplementation(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SignUpDataRepository>(
    () => SignUpDataRepositoryImplementation(flutterSecureStorage: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImplementation(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImplementation(
      firebaseAuth: sl(),
      firebaseFirestore: sl(),
    ),
  );

  sl.registerLazySingleton(() => StaticSkillDataSource());

  // --- Gig Feature ---
  sl.registerFactory(
    () => CreateGigBloc(createNewGigUseCase: sl(), getUserGigsUseCase: sl()),
  );

  sl.registerFactory(() => DiscoverGigBloc(getGigsUseCase: sl()));

  sl.registerLazySingleton(() => CreateNewGigUseCase(repository: sl()));

  sl.registerLazySingleton(() => GetUserGigsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetGigsUseCase(gigRepository: sl()));

  sl.registerLazySingleton<GigRepository>(
    () => GigRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GigRemoteDataSource>(
    () => GigRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  // --- Order Feature ---
  sl.registerFactory(
    () => OrderBloc(createOrderRequestUseCase: sl(), notificationService: sl()),
  );

  sl.registerLazySingleton(
    () => CreateOrderRequestUseCase(orderRepository: sl()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImplementation(remoteRepository: sl()),
  );

  sl.registerLazySingleton<OrderRemoteRepository>(
    () => OrderRemoteRepositoryImplementation(firestore: sl()),
  );

  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // --- Core Services ---
  sl.registerLazySingleton<StorageService>(() => FirebaseStorageService());
  sl.registerLazySingleton(() => PermissionService());
  sl.registerLazySingleton(
    () => NotificationService(messaging: sl(), firestore: sl()),
  );
}
