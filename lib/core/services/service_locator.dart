import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/bloc/phone/phone_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(
    () => AuthBloc(getIsFirstRun: sl(), setOnboardingCompleted: sl()),
  );

  sl.registerFactory(
    () => PhoneBloc(
      signUpDataRepository: sl(),
      requestOtpUseCase: sl(),
      verifyOtpUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetIsFirstRun(sl()));
  sl.registerLazySingleton(() => SetOnboardingComplete(sl()));
  sl.registerLazySingleton(() => RequestOtpUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplementation(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SignUpDataRepository>(
    () => SignUpDataRepositoryImplementation(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImplementation(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImplementation(firebaseAuth: sl()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
