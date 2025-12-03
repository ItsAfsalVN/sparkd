import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/usecases/get_user_profile.dart';
import 'package:sparkd/features/auth/domain/usecases/login_user.dart';
import 'package:sparkd/features/auth/domain/usecases/sign_in_with_google.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final LoginUserUseCase _loginUserUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  SignInBloc({
    required LoginUserUseCase loginUserUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
  }) : _loginUserUseCase = loginUserUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
    on<SignInStatusReset>(_onStatusReset);
    on<SignInWithGoogleRequested>(_onGoogleSignInRequested);
  }

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    final email = event.email;
    final isValid = email.isNotEmpty && email.contains('@');

    emit(
      state.copyWith(
        email: email,
        isEmailValid: isValid,
        status: _validateForm(
          isEmailValid: isValid,
          isPasswordValid: state.isPasswordValid,
        ),
      ),
    );
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    final password = event.password;
    final isValid = password.isNotEmpty && password.length >= 6;

    emit(
      state.copyWith(
        password: password,
        isPasswordValid: isValid,
        status: _validateForm(
          isEmailValid: state.isEmailValid,
          isPasswordValid: isValid,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    if (state.status == FormStatus.valid) {
      emit(state.copyWith(status: FormStatus.submitting, errorMessage: null));

      try {
        await _loginUserUseCase(email: state.email, password: state.password);

        emit(state.copyWith(status: FormStatus.success));
        logger.i("SignInBloc: Login successful for user ${state.email}.");
      } on Exception catch (e) {
        logger.e("SignInBloc: Login failed for user ${state.email}.", error: e);

        emit(
          state.copyWith(
            status: FormStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    } else {
      logger.e("SignInBloc: Submission blocked, form is invalid.");
    }
  }

  void _onStatusReset(SignInStatusReset event, Emitter<SignInState> emit) {
    emit(
      state.copyWith(
        status: _validateForm(
          isEmailValid: state.isEmailValid,
          isPasswordValid: state.isPasswordValid,
        ),
        errorMessage: null,
      ),
    );
  }

  Future<void> _onGoogleSignInRequested(
    SignInWithGoogleRequested event,
    Emitter<SignInState> emit,
  ) async {
    try {
      logger.i('Google Sign-In requested');
      emit(state.copyWith(status: FormStatus.loading));

      final userCredential = await _signInWithGoogleUseCase();
      final user = userCredential.user;

      if (user == null) {
        throw Exception('No user returned from Google Sign-In');
      }

      logger.i('Google Sign-In successful: ${user.email}');

      // Check if user profile exists in Firestore
      logger.i('Checking if user profile exists in Firestore...');
      final userProfile = await _getUserProfileUseCase(user.uid);

      if (userProfile == null) {
        // No profile exists
        if (event.isSignUp) {
          // Sign-up flow: Continue with sign-up process
          logger.i(
            'Google Sign-Up: No profile found for ${user.email}. Continuing with sign-up flow.',
          );
          emit(state.copyWith(status: FormStatus.success));
          return;
        } else {
          // Sign-in flow: User needs to sign up first
          logger.w(
            'No profile found for Google user ${user.email}. User needs to sign up first.',
          );

          // Sign out the user since they don't have an account
          await FirebaseAuth.instance.signOut();

          emit(
            state.copyWith(
              status: FormStatus.failure,
              errorMessage:
                  'No account found with this Google account. Please sign up first.',
            ),
          );
          return;
        }
      }

      // Profile exists
      if (event.isSignUp) {
        // Sign-up flow but user already exists
        logger.w('Google Sign-Up: Account already exists for ${user.email}.');
        await FirebaseAuth.instance.signOut();
        emit(
          state.copyWith(
            status: FormStatus.failure,
            errorMessage:
                'An account with this Google account already exists. Please sign in instead.',
          ),
        );
        return;
      }

      // Sign-in flow with existing profile
      logger.i(
        'User profile found. UserType: ${userProfile.userType}. Login successful.',
      );
      emit(state.copyWith(status: FormStatus.success));
    } catch (error) {
      logger.e('Google Sign-In failed: $error');
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: error.toString().contains('canceled')
              ? 'Sign-in was canceled'
              : error.toString().contains('No account found')
              ? error.toString().replaceAll('Exception: ', '')
              : 'Failed to sign in with Google. Please try again.',
        ),
      );
    }
  }

  FormStatus _validateForm({
    required bool isEmailValid,
    required bool isPasswordValid,
  }) {
    if (isEmailValid && isPasswordValid) {
      return FormStatus.valid;
    } else {
      return FormStatus.invalid;
    }
  }
}
