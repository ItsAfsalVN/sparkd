part of 'skills_bloc.dart';

sealed class SkillsEvent extends Equatable {
  const SkillsEvent();
  @override
  List<Object> get props => [];
}

class SkillsLoadRequested extends SkillsEvent {}

class CategoryToggled extends SkillsEvent {
  final String categoryID;
  const CategoryToggled({required this.categoryID});

  @override
  List<Object> get props => [categoryID];
}

class ToolToggled extends SkillsEvent {
  final String toolID;
  final String categoryID; 
  const ToolToggled({required this.toolID, required this.categoryID});

  @override
  List<Object> get props => [toolID, categoryID];
}

class SkillsSubmitted extends SkillsEvent {}
