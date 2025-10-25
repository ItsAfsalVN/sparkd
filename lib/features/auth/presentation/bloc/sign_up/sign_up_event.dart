part of 'sign_up_bloc.dart';

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpFullNameChanged extends SignUpEvent {
  final String value;
  const SignUpFullNameChanged(this.value);
  @override
  List<Object> get props => [value];
}

class SignUpEmailChanged extends SignUpEvent {
  final String value;
  const SignUpEmailChanged(this.value);
  @override
  List<Object> get props => [value];
}

class SignUpPasswordChanged extends SignUpEvent {
  final String value;
  const SignUpPasswordChanged(this.value);
  @override
  List<Object> get props => [value];
}

class SignUpConfirmPasswordChanged extends SignUpEvent {
  final String value;
  const SignUpConfirmPasswordChanged(this.value);
  @override
  List<Object> get props => [value];
}

class SignUpSubmitted extends SignUpEvent {
  final UserType userType;

  const SignUpSubmitted(this.userType);

  @override
  List<Object> get props => [userType];
} 

class SignUpStatusReset extends SignUpEvent {}
