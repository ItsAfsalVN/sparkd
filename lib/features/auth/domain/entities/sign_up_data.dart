import 'package:equatable/equatable.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';

class SignUpData extends Equatable {
  final String? fullName;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final List<String>? skills;
  final UserType? userType;
  final String? verificationID;
  final String? smsCode;

  const SignUpData({
    this.fullName,
    this.email,
    this.password,
    this.phoneNumber,
    this.skills,
    this.userType,
    this.verificationID,
    this.smsCode
  });

  SignUpData copyWith({
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    List<String>? skills,
    UserType? userType,
    String? verificationID,
    String? smsCode
  }) {
    return SignUpData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      skills: skills ?? this.skills,
      userType: userType ?? this.userType,
      verificationID: verificationID ?? this.verificationID,
      smsCode: smsCode ?? this.smsCode
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
    verificationID,
    smsCode
  ];

  factory SignUpData.fromJson(Map<String, dynamic> json) {
    UserType? parseUserType(String? typeString) {
      if (typeString == null) return null;
      try {
        return UserType.values.firstWhere((e) => e.name == typeString);
      } catch (e) {
        logger.w("Warning: Could not parse UserType '$typeString'. Defaulting.");
        return null;
      }
    }

    return SignUpData(
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      skills: json['skills'] == null
          ? null
          : List<String>.from(json['skills'] as List<dynamic>? ?? []),
      userType: parseUserType(json['userType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'skills': skills,
      'userType': userType?.name,
    };
  }
}
