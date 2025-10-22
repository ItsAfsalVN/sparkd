import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpDataRepository _signUpDataRepository;

  SignUpBloc({required SignUpDataRepository signUpDataRepository})
    : _signUpDataRepository = signUpDataRepository,
      super(const SignUpState()) {
    on<SignUpFullNameChanged>(_onFullNameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
    on<SignUpStatusReset>(_onStatusReset);
  }

  void _onFullNameChanged(
    SignUpFullNameChanged event,
    Emitter<SignUpState> emit,
  ) {
    final fullName = event.value;
    final isValid = fullName.isNotEmpty;

    emit(
      state.copyWith(
        fullName: fullName,
        isFullNameValid: isValid,
        status: _validateForm(
          isFullNameValid: isValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: state.doPasswordsMatch,
        ),
      ),
    );

    final currentData = _signUpDataRepository.getData();
    _signUpDataRepository.updateData(currentData.copyWith(fullName: fullName));
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    final email = event.value;
    final isValid = email.isNotEmpty && email.contains('@');

    emit(
      state.copyWith(
        email: email,
        isEmailValid: isValid,
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: isValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: state.doPasswordsMatch,
        ),
      ),
    );
    final currentData = _signUpDataRepository.getData();
    _signUpDataRepository.updateData(currentData.copyWith(email: email));
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final password = event.value;
    final isValid = password.isNotEmpty && password.length >= 6;
    final doPasswordMatch = password == state.confirmPassword;

    emit(
      state.copyWith(
        password: password,
        isPasswordValid: isValid,
        doPasswordsMatch: doPasswordMatch,
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: isValid,
          doPasswordsMatch: doPasswordMatch,
        ),
      ),
    );

    final currentData = _signUpDataRepository.getData();
    _signUpDataRepository.updateData(currentData.copyWith(password: password));
  }

  void _onConfirmPasswordChanged(
    SignUpConfirmPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    final confirmPassword = event.value;
    final doPasswordMatch = state.password == confirmPassword;

    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        doPasswordsMatch: doPasswordMatch,
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: doPasswordMatch,
        ),
      ),
    );
  }

  void _onSubmitted(SignUpSubmitted event, Emitter<SignUpState> emit) async {
    if (state.status == FormStatus.valid) {
      await Future.delayed(Duration.zero);
      emit(state.copyWith(status: FormStatus.step1Completed));
      print("Current data in repo: ${_signUpDataRepository.getData()}");
    } else {
      print("SignUpBloc: Form submitted but invalid.");
    }
  }

  void _onStatusReset(SignUpStatusReset event, Emitter<SignUpState> emit) {
    emit(
      state.copyWith(
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: state.doPasswordsMatch,
        ),
      ),
    );
  }

  FormStatus _validateForm({
    required bool isFullNameValid,
    required bool isEmailValid,
    required bool isPasswordValid,
    required bool doPasswordsMatch,
  }) {
    if (isFullNameValid &&
        isEmailValid &&
        isPasswordValid &&
        doPasswordsMatch) {
      return FormStatus.valid;
    } else {
      return FormStatus.invalid;
    }
  }
}
