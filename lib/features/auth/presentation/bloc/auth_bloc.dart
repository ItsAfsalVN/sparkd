import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/domain/usecases/get_is_first_run.dart';
import 'package:sparkd/features/auth/domain/usecases/set_onboarding_complete.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetIsFirstRun _getIsFirstRun;
  final SetOnboardingComplete _setOnboardingCompleted;

  final AuthLocalDataSource _localDataSource;
  final SignUpDataRepository _signUpDataRepository;

  AuthBloc({
    required GetIsFirstRun getIsFirstRun,
    required SetOnboardingComplete setOnboardingCompleted,
    required AuthLocalDataSource localDataSource,
    required SignUpDataRepository signUpDataRepository,
  }) : _getIsFirstRun = getIsFirstRun,
       _setOnboardingCompleted = setOnboardingCompleted,
       _localDataSource = localDataSource,
       _signUpDataRepository = signUpDataRepository,
       super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onAuthCheckStatusRequested);
    on<AuthOnboardingCompleted>(_onAuthOnboardingCompleted);
    on<AuthDetailsSubmitted>(_onAuthDetailsSubmitted);
    on<AuthPhoneNumberVerified>(_onAuthPhoneNumberVerified);
    // on<AuthFinalizeSignUp>(_onAuthFinalizeSignUp);
  }

  Future<void> _onAuthCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final bool isFirstRun = await _getIsFirstRun();
      if (isFirstRun) {
        emit(AuthFirstRun());
        logger.i("AuthBloc: First run detected.");
        return;
      }

      final currentStep = await _localDataSource.getCurrentSignUpStep();
      logger.d("AuthBloc: Checking sign up step: $currentStep");

      if (currentStep != null && currentStep != STEP_COMPLETE) {
        final currentData = _signUpDataRepository.getData();

        if (currentStep == STEP_AWAITING_PHONE) {
          emit(AuthAwaitingPhoneNumber(currentData));
          logger.i("AuthBloc: Resuming sign-up at phone input.");
          return;
        } else if (currentStep == STEP_AWAITING_SKILLS) {
          if (FirebaseAuth.instance.currentUser != null) {
            emit(AuthAwaitingSkills(currentData));
            logger.i("AuthBloc: Resuming sign-up at skills input.");
          } else {
            logger.w(
              "AuthBloc: Step is AWAITING_SKILLS but no Firebase user. Resetting.",
            );
            await _localDataSource.clearSignUpStep();
            emit(AuthUnauthenticated());
          }
          return;
        } else if (currentStep == STEP_AWAITING_BUSINESS) {
          if (FirebaseAuth.instance.currentUser != null) {
            emit(AuthAwaitingBusinessDetails(currentData));
            logger.i("AuthBloc: Resuming sign-up at business details input.");
          } else {
            logger.w(
              "AuthBloc: Step is AWAITING_BUSINESS but no Firebase user. Resetting.",
            );
            await _localDataSource.clearSignUpStep();
            emit(AuthUnauthenticated());
          }
          return;
        }
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UserType userType = UserType.spark;
        await _localDataSource.clearSignUpStep();
        emit(AuthAuthenticated(userType));
        logger.i(
          "AuthBloc: User authenticated (sign-up complete or already logged in).",
        );
      } else {
        emit(AuthUnauthenticated());
        logger.i(
          "AuthBloc: Not first run, no pending step, not logged in. Emitting Unauthenticated.",
        );
      }
    } catch (e, s) {
      logger.e("AuthBloc: Error during initial check", error: e, stackTrace: s);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthOnboardingCompleted(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    await _setOnboardingCompleted();

    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthDetailsSubmitted(
    AuthDetailsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _localDataSource.setCurrentSignUpStep(STEP_AWAITING_PHONE);
      final currentData = _signUpDataRepository.getData();
      emit(AuthAwaitingPhoneNumber(currentData));
      logger.d(
        "AuthBloc: Details submitted, saved step STEP_AWAITING_PHONE, emitting AuthAwaitingPhoneNumber.",
      );
    } catch (e) {
      logger.e("AuthBloc: Error saving sign up step", error: e);
    }
  }

  Future<void> _onAuthPhoneNumberVerified(
    AuthPhoneNumberVerified event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final signUpData = _signUpDataRepository.getData();
      final userType = signUpData.userType;
      logger.d("AuthBloc: Phone verified. Checking UserType: $userType");

      String nextStep;
      if (userType == UserType.spark) {
        nextStep = STEP_AWAITING_SKILLS;
      } else if (userType == UserType.sme) {
        nextStep = STEP_AWAITING_BUSINESS;
      } else {
        logger.e(
          "AuthBloc: Unexpected user type ($userType) during phone verification. Clearing step.",
        );
        await _localDataSource.clearSignUpStep();
        emit(AuthUnauthenticated());
        return;
      }

      await _localDataSource.setCurrentSignUpStep(nextStep);

      logger.i("AuthBloc: Phone verified. Saved next step: $nextStep");
    } catch (e) {
      logger.e("AuthBloc: Error saving next step after phone verify", error: e);
    }
  }

  // Future<void> _onAuthFinalizeSignUp() async{

  // }
}
