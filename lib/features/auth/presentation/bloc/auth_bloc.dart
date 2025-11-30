import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/domain/entities/user_profile.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/domain/usecases/create_user_with_email_and_password.dart';
import 'package:sparkd/features/auth/domain/usecases/get_is_first_run.dart';
import 'package:sparkd/features/auth/domain/usecases/get_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/link_phone_credential.dart';
import 'package:sparkd/features/auth/domain/usecases/save_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/set_onboarding_complete.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetIsFirstRun _getIsFirstRun;
  final SetOnboardingComplete _setOnboardingCompleted;

  final AuthLocalDataSource _localDataSource;
  final SignUpDataRepository _signUpDataRepository;

  final CreateUserWithEmailUseCase _createUserWithEmailUseCase;
  final LinkPhoneCredentialUseCase _linkPhoneCredentialUseCase;
  final SaveUserProfileUseCase _saveUserProfileUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  AuthBloc({
    required GetIsFirstRun getIsFirstRun,
    required SetOnboardingComplete setOnboardingCompleted,
    required AuthLocalDataSource localDataSource,
    required SignUpDataRepository signUpDataRepository,
    required CreateUserWithEmailUseCase createUserWithEmailUseCase,
    required LinkPhoneCredentialUseCase linkPhoneCredentialUseCase,
    required SaveUserProfileUseCase saveUserProfileUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
  }) : _getIsFirstRun = getIsFirstRun,
       _setOnboardingCompleted = setOnboardingCompleted,
       _localDataSource = localDataSource,
       _signUpDataRepository = signUpDataRepository,
       _createUserWithEmailUseCase = createUserWithEmailUseCase,
       _linkPhoneCredentialUseCase = linkPhoneCredentialUseCase,
       _saveUserProfileUseCase = saveUserProfileUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onAuthCheckStatusRequested);
    on<AuthOnboardingCompleted>(_onAuthOnboardingCompleted);
    on<AuthDetailsSubmitted>(_onAuthDetailsSubmitted);
    on<AuthPhoneNumberVerified>(_onAuthPhoneNumberVerified);
    on<AuthFinalizeSignUp>(_onAuthFinalizeSignUp);
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

  Future<void> _onAuthFinalizeSignUp(
    AuthFinalizeSignUp event,
    Emitter<AuthState> emit,
  ) async {
    final signUpData = _signUpDataRepository.getData();
    logger.i("AuthBloc: Starting final sign up for user: ${signUpData.email}");
    logger.i(
      "AuthBloc: SignUpData - email: ${signUpData.email}, password exists: ${signUpData.password != null}, userType: ${signUpData.userType}",
    );

    // Check if critical data is available
    if (signUpData.verificationID == null ||
        signUpData.smsCode == null ||
        signUpData.phoneNumber == null ||
        signUpData.userType == null) {
      logger.e("AuthBloc: Missing critical data for final sign up. Aborting.");
      logger.e(
        "AuthBloc: verificationID: ${signUpData.verificationID}, smsCode: ${signUpData.smsCode}, phone: ${signUpData.phoneNumber}, userType: ${signUpData.userType}",
      );

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

      // Check if user is already signed in (e.g., via Google Sign-In)
      if (currentUser == null) {
        // User not signed in, create account with email/password
        if (signUpData.email == null || signUpData.password == null) {
          logger.e("AuthBloc: Email/password missing for account creation.");
          logger.e(
            "AuthBloc: This likely means Google Sign-In user was signed out. Email: ${signUpData.email}, Password exists: ${signUpData.password != null}",
          );
          throw Exception("Email and password are required for sign up.");
        }

        logger.i("AuthBloc: Creating new user with email/password...");
        final userCredential = await _createUserWithEmailUseCase(
          email: signUpData.email!,
          password: signUpData.password!,
        );
        currentUser = userCredential.user;
        if (currentUser == null) {
          throw Exception("Firebase user object is null after creation.");
        }
        logger.i(
          "AuthBloc: Email/Pass user created successfully. UID: ${currentUser.uid}",
        );
      } else {
        logger.i(
          "AuthBloc: User already signed in (likely via Google). UID: ${currentUser.uid}, Email: ${currentUser.email}",
        );
      }

      // Link phone number to the account
      logger.i("AuthBloc: Linking phone number to user account...");
      await _linkPhoneCredentialUseCase(
        verificationID: signUpData.verificationID!,
        smsCode: signUpData.smsCode!,
        phoneNumber: signUpData.phoneNumber!,
      );
      logger.i("AuthBloc: Phone number linked successfully.");

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

      await _localDataSource.clearSignUpStep();
      _signUpDataRepository.clearData();

      emit(AuthUnauthenticated());
    }
  }
}
