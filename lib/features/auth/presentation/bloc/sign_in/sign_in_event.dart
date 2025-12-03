part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInEmailChanged extends SignInEvent {
  final String email;
  const SignInEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class SignInPasswordChanged extends SignInEvent {
  final String password;
  const SignInPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class SignInSubmitted extends SignInEvent {
  const SignInSubmitted();

  @override
  List<Object> get props => [];
}

class SignInStatusReset extends SignInEvent {
  const SignInStatusReset();

  @override
  List<Object> get props => [];
}

class SignInWithGoogleRequested extends SignInEvent {
  final bool isSignUp;
  const SignInWithGoogleRequested({this.isSignUp = false});

  @override
  List<Object> get props => [isSignUp];
}
