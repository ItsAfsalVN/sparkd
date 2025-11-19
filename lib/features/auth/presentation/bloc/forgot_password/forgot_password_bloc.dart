import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/form_statuses.dart';
import 'package:sparkd/features/auth/domain/usecases/forgot_password.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  ForgotPasswordBloc({required ForgotPasswordUseCase forgotPasswordUseCase})
    : _forgotPasswordUseCase = forgotPasswordUseCase,
      super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    final email = event.email;
    final isEmailValid = email.contains('@') && email.contains('.');

    emit(
      state.copyWith(
        email: email,
        isEmailValid: isEmailValid,
        status: isEmailValid ? FormStatus.valid : FormStatus.invalid,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (!state.isEmailValid) {
      emit(
        state.copyWith(
          status: FormStatus.invalid,
          errorMessage: 'Please enter a valid email address.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting, errorMessage: null));

    try {
      await _forgotPasswordUseCase.call(email: state.email);
      emit(state.copyWith(status: FormStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: FormStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
