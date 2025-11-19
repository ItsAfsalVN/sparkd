part of 'forgot_password_bloc.dart';

class ForgotPasswordState extends Equatable {
  final String email;
  final bool isEmailValid;
  final String? errorMessage;
  final FormStatus status;

  const ForgotPasswordState({
    this.email = '',
    this.isEmailValid = false,
    this.errorMessage,
    this.status = FormStatus.initial,
  });

  ForgotPasswordState copyWith({
    String? email,
    bool? isEmailValid,
    String? errorMessage,
    FormStatus? status,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
  
  @override
  List<Object> get props => [email, isEmailValid, errorMessage ?? '', status];
}


