import 'package:equatable/equatable.dart';

enum RequirementType { text, file }

class RequirementEntity extends Equatable {
  final String description;
  final RequirementType type;

  const RequirementEntity({required this.description, required this.type});

  @override
  List<Object?> get props => [description, type];

  RequirementEntity copyWith({String? description, RequirementType? type}) {
    return RequirementEntity(
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {'description': description, 'type': type.name};
  }

  factory RequirementEntity.fromMap(Map<String, dynamic> map) {
    return RequirementEntity(
      description: map['description'] as String,
      type: RequirementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RequirementType.text,
      ),
    );
  }
}
