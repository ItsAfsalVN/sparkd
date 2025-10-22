import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/auth/domain/usecases/get_is_first_run.dart';
import 'package:sparkd/features/auth/domain/usecases/set_onboarding_complete.dart'; 

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final GetIsFirstRun _getIsFirstRun;
  final SetOnboardingComplete _setOnboardingCompleted;

  AuthBloc({
    required GetIsFirstRun getIsFirstRun,
    required SetOnboardingComplete setOnboardingCompleted,
  }) : _getIsFirstRun = getIsFirstRun,
       _setOnboardingCompleted = setOnboardingCompleted,
       super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onAuthCheckStatusRequested);
    on<AuthOnboardingCompleted>(_onAuthOnboardingCompleted);
  }

  // Method to check if authenticated
  Future<void> _onAuthCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final bool isFirstRun = await _getIsFirstRun();

    const bool isLoggedIn = false;
    const UserType userType = UserType.spark;

    if (isFirstRun) {
      emit(AuthFirstRun());
    } else if (!isLoggedIn) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(userType));
    }
  }

  // The method to change isFirstRun to false to not show the Onboarding screens
  Future<void> _onAuthOnboardingCompleted(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    await _setOnboardingCompleted(); 

    // Now that the flag is saved, emit the next state
    emit(AuthUnauthenticated());
  }
}
