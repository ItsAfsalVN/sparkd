import 'package:equatable/equatable.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/spark/data/models/skill_model.dart';
import 'package:sparkd/core/utils/logger.dart';

class SignUpData extends Equatable {
  final String? fullName;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final List<SkillModel>? skills;
  final UserType? userType;
  final String? verificationID;
  final String? smsCode;
  final Map<String, dynamic>? businessData;

  const SignUpData({
    this.fullName,
    this.email,
    this.password,
    this.phoneNumber,
    this.skills,
    this.userType,
    this.verificationID,
    this.smsCode,
    this.businessData,
  });

  SignUpData copyWith({
    String? fullName,
    String? email,
    String? password,
    String? phoneNumber,
    List<SkillModel>? skills,
    UserType? userType,
    String? verificationID,
    String? smsCode,
    Map<String, dynamic>? businessData,
  }) {
    return SignUpData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      skills: skills ?? this.skills,
      userType: userType ?? this.userType,
      verificationID: verificationID ?? this.verificationID,
      smsCode: smsCode ?? this.smsCode,
      businessData: businessData ?? this.businessData,
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
    smsCode,
    businessData,
  ];

  factory SignUpData.fromJson(Map<String, dynamic> json) {
    UserType? parseUserType(String? typeString) {
      if (typeString == null) return null;
      try {
        return UserType.values.firstWhere((e) => e.name == typeString);
      } catch (e) {
        logger.w(
          "Warning: Could not parse UserType '$typeString'. Defaulting.",
        );
        return null;
      }
    }

    return SignUpData(
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      verificationID: json['verificationID'] as String?,
      smsCode: json['smsCode'] as String?,
      userType: parseUserType(json['userType'] as String?),
      businessData: json['businessData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'skills': skills?.map((e) => e.toJson()).toList(),
      'userType': userType?.name,
      'verificationID': verificationID,
      'smsCode': smsCode,
      'businessData': businessData,
    };
  }
}
