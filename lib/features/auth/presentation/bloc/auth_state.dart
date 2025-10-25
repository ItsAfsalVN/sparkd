part of 'auth_bloc.dart';

enum UserType { spark, sme, admin }

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state
class AuthInitial extends AuthState {}

// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserType userType;
  const AuthAuthenticated(this.userType);

  @override
  List<Object> get props => [userType];
}

// User is unauthenticated
class AuthUnauthenticated extends AuthState {}

// Users first time on the app
class AuthFirstRun extends AuthState {}

class AuthAwaitingPhoneNumber extends AuthState {
  final SignUpData signUpData;
  const AuthAwaitingPhoneNumber(this.signUpData);

  @override
  List<Object> get props => [signUpData];
}

class AuthAwaitingSkills extends AuthState {
  final SignUpData signUpData;

  const AuthAwaitingSkills(this.signUpData);

  @override
  List<Object> get props => [signUpData];
}

class AuthAwaitingBusinessDetails extends AuthState {
  final SignUpData signUpData;

  const AuthAwaitingBusinessDetails(this.signUpData);

  @override
  List<Object> get props => [signUpData];
}
