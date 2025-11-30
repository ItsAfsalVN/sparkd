import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/core/utils/form_statuses.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpDataRepository _signUpDataRepository;

  SignUpBloc({required SignUpDataRepository signUpDataRepository})
    : _signUpDataRepository = signUpDataRepository,
      super(_initialState(signUpDataRepository)) {
    on<SignUpFullNameChanged>(_onFullNameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
    on<SignUpStatusReset>(_onStatusReset);
  }

  static SignUpState _initialState(SignUpDataRepository repository) {
    final savedData = repository.getData();

    final fullName = savedData.fullName ?? '';
    final email = savedData.email ?? '';
    final password = savedData.password ?? '';
    final confirmPassword =
        savedData.password ?? ''; // Use saved password for confirm password

    final isFullNameValid = fullName.isNotEmpty;
    // More comprehensive email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final isEmailValid = email.isNotEmpty && emailRegex.hasMatch(email);
    final isPasswordValid = password.isNotEmpty && password.length >= 6;
    final doPasswordsMatch = password == confirmPassword;

    FormStatus initialStatus = FormStatus.invalid;
    if (isFullNameValid &&
        isEmailValid &&
        isPasswordValid &&
        doPasswordsMatch) {
      initialStatus = FormStatus.valid;
    }

    return SignUpState(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      isFullNameValid: isFullNameValid,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      doPasswordsMatch: doPasswordsMatch,
      status: initialStatus,
    );
  }

  void _onFullNameChanged(
    SignUpFullNameChanged event,
    Emitter<SignUpState> emit,
  ) {
    final fullName = event.value;
    final isValid = fullName.isNotEmpty;
    final doPasswordsMatch = state.password == state.confirmPassword;
    emit(
      state.copyWith(
        fullName: fullName,
        isFullNameValid: isValid,
        doPasswordsMatch: doPasswordsMatch,
        status: _validateForm(
          isFullNameValid: isValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: doPasswordsMatch,
        ),
      ),
    );
    final currentData = _signUpDataRepository.getData();
    _signUpDataRepository.updateData(currentData.copyWith(fullName: fullName));
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    final email = event.value;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final isValid = email.isNotEmpty && emailRegex.hasMatch(email);
    final doPasswordsMatch = state.password == state.confirmPassword;
    emit(
      state.copyWith(
        email: email,
        isEmailValid: isValid,
        doPasswordsMatch: doPasswordsMatch,
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: isValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: doPasswordsMatch,
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
    final doPasswordsMatch = password == state.confirmPassword;
    emit(
      state.copyWith(
        password: password,
        isPasswordValid: isValid,
        doPasswordsMatch: doPasswordsMatch,
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: isValid,
          doPasswordsMatch: doPasswordsMatch,
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
    final doPasswordsMatch = state.password == confirmPassword;
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        doPasswordsMatch: doPasswordsMatch,
        status: _validateForm(
          isFullNameValid: state.isFullNameValid,
          isEmailValid: state.isEmailValid,
          isPasswordValid: state.isPasswordValid,
          doPasswordsMatch: doPasswordsMatch,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (state.status == FormStatus.valid) {
      final currentData = _signUpDataRepository.getData();
      _signUpDataRepository.updateData(
        currentData.copyWith(userType: event.userType),
      );
      logger.d(
        "SignUpBloc: Saved userType '${event.userType}' to repository on submit.",
      );

      // Verify the save
      final verifyData = _signUpDataRepository.getData();
      logger.i(
        "SignUpBloc: VERIFICATION - UserType after save: ${verifyData.userType}",
      );

      await Future.delayed(Duration.zero);

      if (!isClosed && state.status == FormStatus.valid) {
        emit(state.copyWith(status: FormStatus.detailsSubmitted));
        logger.i(
          "SignUpBloc: Form valid, emitting FormStatus.detailsSubmitted.",
        );
        logger.i("Current data in repo: ${_signUpDataRepository.getData()}");
      }
    } else {
      logger.e("SignUpBloc: Form submitted but invalid.");
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
    // Form is valid if all individual fields are valid and passwords match
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
