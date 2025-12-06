import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/domain/entities/user_profile.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/domain/usecases/create_user_with_email_and_password.dart';
import 'package:sparkd/features/auth/domain/usecases/get_is_first_run.dart';
import 'package:sparkd/features/auth/domain/usecases/get_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/logout.dart';
import 'package:sparkd/features/auth/domain/usecases/save_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/set_onboarding_complete.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetIsFirstRun _getIsFirstRun;
  final NotificationService _notificationService;
  final SetOnboardingComplete _setOnboardingCompleted;

  final AuthLocalDataSource _localDataSource;
  final SignUpDataRepository _signUpDataRepository;

  final CreateUserWithEmailUseCase _createUserWithEmailUseCase;
  final SaveUserProfileUseCase _saveUserProfileUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required GetIsFirstRun getIsFirstRun,
    required SetOnboardingComplete setOnboardingCompleted,
    required AuthLocalDataSource localDataSource,
    required SignUpDataRepository signUpDataRepository,
    required CreateUserWithEmailUseCase createUserWithEmailUseCase,
    required SaveUserProfileUseCase saveUserProfileUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required NotificationService notificationService,
  }) : _getIsFirstRun = getIsFirstRun,
       _setOnboardingCompleted = setOnboardingCompleted,
       _localDataSource = localDataSource,
       _signUpDataRepository = signUpDataRepository,
       _createUserWithEmailUseCase = createUserWithEmailUseCase,
       _saveUserProfileUseCase = saveUserProfileUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       _logoutUseCase = logoutUseCase,
       _notificationService = notificationService,
       super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onAuthCheckStatusRequested);
    on<AuthOnboardingCompleted>(_onAuthOnboardingCompleted);
    on<AuthDetailsSubmitted>(_onAuthDetailsSubmitted);
    on<AuthPhoneNumberVerified>(_onAuthPhoneNumberVerified);
    on<AuthFinalizeSignUp>(_onAuthFinalizeSignUp);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
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
            _signUpDataRepository.clearData();
            emit(AuthUnauthenticated());
          }
          return;
        } else if (currentStep == STEP_AWAITING_BUSINESS) {
          // For SME users, they can be at business details step without full Firebase auth
          // The phone verification created a temporary user, but session might expire
          // We should still let them continue and provide their business details
          emit(AuthAwaitingBusinessDetails(currentData));
          logger.i("AuthBloc: Resuming sign-up at business details input.");
          return;
        }
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // User is authenticated - fetch their profile from Firestore
        logger.i(
          "AuthBloc: Firebase user found (${currentUser.uid}). Fetching user profile...",
        );
        try {
          final userProfile = await _getUserProfileUseCase(currentUser.uid);
          if (userProfile != null) {
            logger.i(
              "AuthBloc: User profile loaded. UserType: ${userProfile.userType}",
            );
            await _localDataSource.clearSignUpStep();

            // Save FCM token for notifications
            try {
              await _notificationService.saveTokenToUser(currentUser.uid);
              logger.i(
                "AuthBloc: FCM token saved for user: ${currentUser.uid}",
              );
            } catch (e) {
              logger.e("AuthBloc: Failed to save FCM token: $e");
            }

            emit(AuthAuthenticated(userProfile.userType));
            return;
          } else {
            logger.w(
              "AuthBloc: No profile found in Firestore for UID: ${currentUser.uid}",
            );
          }
        } catch (e) {
          logger.e(
            "AuthBloc: Error fetching user profile from Firestore",
            error: e,
          );
        }
        // If we couldn't get the profile, sign out and show unauthenticated
        await FirebaseAuth.instance.signOut();
        await _localDataSource.clearSignUpStep();
        emit(AuthUnauthenticated());
        logger.w("AuthBloc: Could not load user profile. User signed out.");
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
      final currentData = _signUpDataRepository.getData();
      logger.i(
        "AuthBloc: Details submitted. UserType: ${currentData.userType}",
      );

      // Create Firebase Auth user with email/password NOW (before OTP)
      // This allows us to link phone credential immediately after OTP verification
      if (currentData.email != null && currentData.password != null) {
        final existingUser = FirebaseAuth.instance.currentUser;

        // Only create if not already signed in (Google users are already signed in)
        if (existingUser == null) {
          logger.i(
            "AuthBloc: Creating Firebase Auth user with email/password...",
          );
          try {
            final userCredential = await _createUserWithEmailUseCase(
              email: currentData.email!,
              password: currentData.password!,
            );
            logger.i(
              "AuthBloc: Email/Pass user created successfully. UID: ${userCredential.user?.uid}",
            );
          } catch (e) {
            logger.e(
              "AuthBloc: Error creating user with email/password",
              error: e,
            );
            // If user already exists, try to sign in
            // This can happen if the flow was interrupted before
            logger.w("AuthBloc: User might already exist, continuing...");
          }
        } else {
          logger.i(
            "AuthBloc: User already signed in (Google). UID: ${existingUser.uid}",
          );
        }
      }

      await _localDataSource.setCurrentSignUpStep(STEP_AWAITING_PHONE);
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
      logger.d("AuthBloc: Phone verified. UserType: $userType");

      // User account is already created (in AuthDetailsSubmitted)
      // Phone credential is already linked (in verifyOtp)
      // Just determine the next step

      String nextStep;
      if (userType == UserType.spark) {
        nextStep = STEP_AWAITING_SKILLS;
      } else if (userType == UserType.sme) {
        nextStep = STEP_AWAITING_BUSINESS;
      } else {
        logger.e(
          "AuthBloc: Unexpected user type ($userType) during phone verification.",
        );
        await _localDataSource.clearSignUpStep();
        emit(AuthUnauthenticated());
        return;
      }

      await _localDataSource.setCurrentSignUpStep(nextStep);
      logger.i("AuthBloc: Phone verified and linked. Next step: $nextStep");
    } catch (e, s) {
      logger.e(
        "AuthBloc: Error during phone verification step",
        error: e,
        stackTrace: s,
      );
      await _localDataSource.clearSignUpStep();
      _signUpDataRepository.clearData();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthFinalizeSignUp(
    AuthFinalizeSignUp event,
    Emitter<AuthState> emit,
  ) async {
    final signUpData = _signUpDataRepository.getData();
    logger.i("AuthBloc: Finalizing sign up for user: ${signUpData.email}");
    logger.i(
      "AuthBloc: SignUpData - email: ${signUpData.email}, userType: ${signUpData.userType}",
    );

    // Check if critical data is available
    if (signUpData.userType == null) {
      logger.e("AuthBloc: Missing userType for final sign up. Aborting.");
      _signUpDataRepository.clearData();
      await _localDataSource.clearSignUpStep();
      emit(AuthUnauthenticated());
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      logger.i(
        "AuthBloc: Current Firebase user: ${currentUser?.uid ?? 'null'}, email: ${currentUser?.email ?? 'null'}",
      );

      if (currentUser == null) {
        logger.e(
          "AuthBloc: No authenticated user found. This should not happen.",
        );
        throw Exception("No authenticated user found.");
      }

      // Phone is already linked at this point, just save the profile
      logger.i("AuthBloc: Creating user profile for Firestore...");
      final UserProfile userProfile = UserProfile.fromSignUpData(
        currentUser.uid,
        signUpData,
      );

      logger.i(
        "AuthBloc: Created UserProfile - userType: ${userProfile.userType}, "
        "skills: ${userProfile.skills?.length ?? 0}, "
        "businessData: ${userProfile.businessData != null ? 'present' : 'null'}",
      );

      if (userProfile.businessData != null) {
        logger.d(
          "AuthBloc: Business data to save: ${userProfile.businessData}",
        );
      }

      await _saveUserProfileUseCase(userProfile);
      logger.i("AuthBloc: User profile successfully persisted to Firestore.");

      await _localDataSource.clearSignUpStep();
      _signUpDataRepository.clearData();

      emit(AuthAuthenticated(signUpData.userType!));
      logger.i("AuthBloc: Sign-up finalized. Emitting AuthAuthenticated.");
    } catch (e, s) {
      logger.e(
        "AuthBloc: Fatal Error during Final Sign Up/Linking.",
        error: e,
        stackTrace: s,
      );

      final errorString = e.toString();
      final isSessionExpired =
          errorString.contains('session-expired') ||
          errorString.contains('sms code has expired');

      if (isSessionExpired) {
        logger.w(
          "AuthBloc: OTP session expired. User needs to re-verify phone.",
        );
        // Don't clear data - keep user at phone verification step
        await _localDataSource.setCurrentSignUpStep(STEP_AWAITING_PHONE);
        emit(
          AuthFinalizationError(
            errorMessage:
                'Your verification code has expired. Please verify your phone number again.',
            signUpData: signUpData,
            isSessionExpired: true,
          ),
        );
      } else {
        // Other errors - clear everything and restart
        logger.e("AuthBloc: Unrecoverable error. Clearing sign-up data.");
        await _localDataSource.clearSignUpStep();
        _signUpDataRepository.clearData();
        emit(
          AuthFinalizationError(
            errorMessage: 'Failed to complete sign-up. Please try again.',
            signUpData: signUpData,
            isSessionExpired: false,
          ),
        );
      }
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      logger.i("AuthBloc: Logout requested");
      await _logoutUseCase();
      logger.i("AuthBloc: User logged out successfully");
      emit(AuthUnauthenticated());
    } catch (e, s) {
      logger.e("AuthBloc: Error during logout", error: e, stackTrace: s);
      // Even if logout fails, navigate to unauthenticated state
      emit(AuthUnauthenticated());
    }
  }
}
