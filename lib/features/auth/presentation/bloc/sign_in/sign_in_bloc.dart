import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/usecases/login_user.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final LoginUserUseCase _loginUserUseCase;

  SignInBloc({required LoginUserUseCase loginUserUseCase})
    : _loginUserUseCase = loginUserUseCase,
      super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
    on<SignInStatusReset>(_onStatusReset);
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
