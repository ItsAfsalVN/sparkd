import 'package:equatable/equatable.dart';

class ToolEntity extends Equatable{
  final String toolID;
  final String toolName;

  const ToolEntity({required this.toolID, required this.toolName});

  @override
  List<Object> get props => [toolID, toolName];
}

class SkillEntity extends Equatable {
  final String categoryID;
  final String categoryName;
  final List<ToolEntity> tools;

  const SkillEntity({required this.categoryID,required this.categoryName, required this.tools});

  @override
  List<Object?> get props => [categoryID,categoryName,tools];
}