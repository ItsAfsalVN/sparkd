import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:sparkd/features/auth/domain/entities/sign_up_data.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/spark/data/models/skill_model.dart';

class UserProfile extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserType userType;
  final List<SkillModel>? skills;
  final Map<String, dynamic>? businessData; // For SME users

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.skills,
    this.businessData,
  });

  factory UserProfile.fromSignUpData(String uid, SignUpData data) {
    return UserProfile(
      uid: uid,
      fullName: data.fullName!,
      email: data.email!,
      phoneNumber: data.phoneNumber!,
      userType: data.userType!,
      skills: data.skills,
      businessData: data.businessData,
    );
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    UserType parseUserType(String? typeString) {
      if (typeString == null) return UserType.spark;
      try {
        return UserType.values.firstWhere((e) => e.name == typeString);
      } catch (e) {
        return UserType.spark;
      }
    }

    try {
      final uid = data['uid'] as String?;
      final fullName = data['fullName'] as String?;
      final email = data['email'] as String?;
      final phoneNumber = data['phoneNumber'] as String? ?? '';

      if (uid == null || fullName == null || email == null) {
        throw FormatException(
          'Missing required fields. Expected: uid, fullName, email. '
          'Found: ${data.keys.join(", ")}',
        );
      }

      // Parse skills with error handling
      List<SkillModel>? parsedSkills;
      try {
        parsedSkills = (data['skills'] as List<dynamic>?)?.map((e) {
          if (e is! Map<String, dynamic>) {
            throw FormatException('Skill item is not a map');
          }
          return SkillModel.fromJson(e);
        }).toList();
      } catch (skillError) {
        throw FormatException('Failed to parse skills: $skillError');
      }

      return UserProfile(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        userType: parseUserType(data['userType'] as String?),
        skills: parsedSkills,
        businessData: data['businessData'] as Map<String, dynamic>?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType.name,
      'profileComplete': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add skills for Spark users
    if (skills != null && skills!.isNotEmpty) {
      data['skills'] = skills!.map((s) => s.toJson()).toList();
    }

    // Add business data for SME users
    if (businessData != null && businessData!.isNotEmpty) {
      data['businessData'] = businessData;
    }

    return data;
  }

  @override
  List<Object?> get props => [uid, fullName, userType, skills, businessData];
}
