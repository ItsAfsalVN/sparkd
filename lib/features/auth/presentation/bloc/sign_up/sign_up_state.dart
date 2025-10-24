part of 'sign_up_bloc.dart';

// You can use an enum to track the overall form status
enum FormStatus {
  initial,
  invalid,
  valid,
  submitting,
  otpSent,
  failure,
  success,
  step1Completed,
}

class SignUpState extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  final bool isFullNameValid;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool doPasswordsMatch;
  final String? errorMessage;

  final FormStatus status;

  const SignUpState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isFullNameValid = true,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.doPasswordsMatch = true,
    this.errorMessage,
    this.status = FormStatus.initial,
  });

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isFullNameValid,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? doPasswordsMatch,
    String? errorMessage,
    FormStatus? status,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isFullNameValid: isFullNameValid ?? this.isFullNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      doPasswordsMatch: doPasswordsMatch ?? this.doPasswordsMatch,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
    confirmPassword,
    isFullNameValid,
    isEmailValid,
    isPasswordValid,
    doPasswordsMatch,
    errorMessage,
    status,
  ];
}
