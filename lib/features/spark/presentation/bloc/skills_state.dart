part of 'skills_bloc.dart';


class SkillsState extends Equatable {
  
  final List<SkillEntity> availableSkills;

  final String? focusedCategoryID;

  final List<SkillModel> selectedSkills;

  final FormStatus status;
  final String? errorMessage;

  const SkillsState({
    this.availableSkills = const [],
    this.focusedCategoryID,
    this.selectedSkills = const [],
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  bool isCategorySelected(String categoryID) =>
      selectedSkills.any((s) => s.categoryID == categoryID);

  bool isToolSelected(String categoryID, String toolID) {
    final skill = selectedSkills.firstWhere(
      (s) => s.categoryID == categoryID,
      orElse: () =>
          SkillModel(categoryID: '', categoryName: '', tools: const []),
    );
    return skill.tools.any((t) => t.toolID == toolID);
  }

  SkillsState copyWith({
    List<SkillEntity>? availableSkills,
    String? focusedCategoryID,
    List<SkillModel>? selectedSkills,
    FormStatus? status,
    String? errorMessage,
  }) {
    return SkillsState(
      availableSkills: availableSkills ?? this.availableSkills,
      focusedCategoryID: focusedCategoryID,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    availableSkills,
    focusedCategoryID,
    selectedSkills,
    status,
    errorMessage,
  ];
}
