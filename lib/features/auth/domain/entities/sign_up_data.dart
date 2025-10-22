import 'package:equatable/equatable.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';

class SignUpData extends Equatable {
  final String? fullName;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final List<String>? skills;
  final UserType? userType;

  const SignUpData({
    this.fullName,
    this.email,
    this.password,
    this.phoneNumber,
    this.skills,
    this.userType,
  });

  SignUpData copyWith({
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    List<String>? skills,
    UserType? userType,
  }) {
    return SignUpData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      skills: skills ?? this.skills,
      userType: userType ?? this.userType,
    );
  }

  static const empty = SignUpData();

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
    phoneNumber,
    skills,
    userType,
  ];
}
