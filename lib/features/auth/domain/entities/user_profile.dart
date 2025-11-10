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
  // final BusinessDetailsModel? businessDetails; // For SME users (to be implemented)

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.skills,
  });

  factory UserProfile.fromSignUpData(String uid, SignUpData data) {

    return UserProfile(
      uid: uid,
      fullName: data.fullName!,
      email: data.email!,
      phoneNumber: data.phoneNumber!,
      userType: data.userType!,
      skills: data.skills,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType.name,
      'skills': skills
          ?.map((s) => s.toJson())
          .toList(), 
      'profileComplete': true, 
      'createdAt': FieldValue.serverTimestamp(), 
    };
  }

  @override
  List<Object?> get props => [uid, fullName, userType, skills];
}
