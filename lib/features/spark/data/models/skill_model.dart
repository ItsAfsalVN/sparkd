import 'package:sparkd/features/spark/domain/entities/skill_entity.dart';

class ToolModel extends ToolEntity {
  const ToolModel({required super.toolID, required super.toolName});

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      toolID: json['id'] as String,
      toolName: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': toolID, 'name': toolName};
  }

  factory ToolModel.fromEntity(ToolEntity entity) {
    return ToolModel(toolID: entity.toolID, toolName: entity.toolName);
  }
}

class SkillModel extends SkillEntity {
  const SkillModel({
    required super.categoryID,
    required super.categoryName,
    required super.tools,
  });

  SkillModel copyWith({
    String? categoryID,
    String? categoryName,
    List<ToolModel>? tools,
  }) {
    return SkillModel(
      categoryID: categoryID ?? this.categoryID,
      categoryName: categoryName ?? this.categoryName,
      tools: tools ?? this.tools,
    );
  }

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      categoryID: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      tools: (json['tools'] as List<dynamic>)
          .map((e) => ToolModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryID,
      'categoryName': categoryName,
      'tools': tools.map((e) => (e as ToolModel).toJson()).toList(),
    };
  }

  factory SkillModel.fromEntity(SkillEntity entity) {
    return SkillModel(
      categoryID: entity.categoryID,
      categoryName: entity.categoryName,
      tools: entity.tools.map((e) => ToolModel.fromEntity(e)).toList(),
    );
  }
}
