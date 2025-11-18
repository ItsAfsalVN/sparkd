import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/spark/data/datasources/static_skill_data_source.dart';
import 'package:sparkd/features/spark/data/models/skill_model.dart';
import 'package:sparkd/features/spark/domain/entities/skill_entity.dart';
import 'package:sparkd/core/utils/form_statuses.dart';

part 'skills_event.dart';
part 'skills_state.dart';

class SkillsBloc extends Bloc<SkillsEvent, SkillsState> {
  final SignUpDataRepository _signUpDataRepository;
  final StaticSkillDataSource _staticDataSource;

  SkillsBloc({
    required SignUpDataRepository signUpDataRepository,
    required StaticSkillDataSource staticDataSource,
  }) : _signUpDataRepository = signUpDataRepository,
       _staticDataSource = staticDataSource,
       super(const SkillsState()) {
    on<SkillsLoadRequested>(_onSkillsLoadRequested);
    on<CategoryToggled>(_onCategoryToggled);
    on<ToolToggled>(_onToolToggled);
    on<SkillsSubmitted>(_onSkillsSubmitted);
  }

  void _onSkillsLoadRequested(
    SkillsLoadRequested event,
    Emitter<SkillsState> emit,
  ) {
    emit(state.copyWith(status: FormStatus.loading));
    try {
      final rawData = _staticDataSource.getCategoriesWithTools();

      final List<SkillEntity> availableSkills = rawData.map((map) {
        final tools = (map['tools'] as List<Map<String, dynamic>>)
            .map(
              (t) => ToolEntity(
                toolID: t['id'] as String,
                toolName: t['name'] as String,
              ),
            )
            .toList();

        return SkillEntity(
          categoryID: map['categoryId'] as String,
          categoryName: map['categoryName'] as String,
          tools: tools,
        );
      }).toList();

      logger.i(
        "SkillsBloc: Loaded ${availableSkills.length} skill categories.",
      );

      emit(
        state.copyWith(
          availableSkills: availableSkills,
          status: FormStatus.loaded,
        ),
      );
    } catch (e, s) {
      logger.e("SkillsBloc: Failed to load skills", error: e, stackTrace: s);
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: "Failed to load skill data.",
        ),
      );
    }
  }

  void _onCategoryToggled(CategoryToggled event, Emitter<SkillsState> emit) {
    final toggledId = event.categoryID;

    final newFocusedId = state.focusedCategoryID == toggledId
        ? null
        : toggledId;

    List<SkillModel> newSelectedSkills = List.from(state.selectedSkills);
    final existingIndex = newSelectedSkills.indexWhere(
      (s) => s.categoryID == toggledId,
    );

    if (existingIndex == -1) {
      final entity = state.availableSkills.firstWhere(
        (s) => s.categoryID == toggledId,
      );
      newSelectedSkills.add(
        SkillModel(
          categoryID: entity.categoryID,
          categoryName: entity.categoryName,
          tools: const [],
        ),
      );
    } else {
      final existingSkill = newSelectedSkills[existingIndex];

      if (existingSkill.tools.isEmpty) {
        newSelectedSkills.removeAt(existingIndex);
        if (state.focusedCategoryID == toggledId) {
          emit(
            state.copyWith(
              focusedCategoryID: null,
              selectedSkills: newSelectedSkills,
            ),
          );
          return;
        }
      }
    }

    emit(
      state.copyWith(
        focusedCategoryID: newFocusedId,
        selectedSkills: newSelectedSkills,
      ),
    );
  }

  void _onToolToggled(ToolToggled event, Emitter<SkillsState> emit) {
    List<SkillModel> newSelectedSkills = List.from(state.selectedSkills);
    final existingSkillIndex = newSelectedSkills.indexWhere(
      (s) => s.categoryID == event.categoryID,
    );

    if (existingSkillIndex == -1) {
      logger.w(
        "SkillsBloc: Attempted to toggle tool before category was selected.",
      );
      return;
    }

    final existingSkill = newSelectedSkills[existingSkillIndex];
    List<ToolModel> newTools = List.from(existingSkill.tools);
    final toolIndex = newTools.indexWhere((t) => t.toolID == event.toolID);

    final availableCategory = state.availableSkills.firstWhere(
      (s) => s.categoryID == event.categoryID,
    );
    final toolEntity = availableCategory.tools.firstWhere(
      (t) => t.toolID == event.toolID,
    );
    final toolModel = ToolModel.fromEntity(toolEntity);

    if (toolIndex == -1) {
      newTools.add(toolModel);
    } else {
      newTools.removeAt(toolIndex);
    }

    final updatedSkill = existingSkill.copyWith(tools: newTools);

    newSelectedSkills[existingSkillIndex] = updatedSkill;

    emit(state.copyWith(selectedSkills: newSelectedSkills));
  }

  Future<void> _onSkillsSubmitted(
    SkillsSubmitted event,
    Emitter<SkillsState> emit,
  ) async {
    if (state.selectedSkills.isEmpty) {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: "Please select at least one skill category.",
        ),
      );
      return;
    }

    final hasToolsSelected = state.selectedSkills.any(
      (skill) => skill.tools.isNotEmpty,
    );

    if (!hasToolsSelected) {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage:
              "Please select at least one tool from your chosen categories.",
        ),
      );
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting));

    try {
      final currentData = _signUpDataRepository.getData();
      _signUpDataRepository.updateData(
        currentData.copyWith(skills: state.selectedSkills),
      );
      logger.i("SkillsBloc: Saved final skills to repository.");

      final AuthBloc authBloc = di.sl<AuthBloc>();
      logger.i("SkillsBloc: AuthBloc instance hashCode: ${authBloc.hashCode}");
      logger.i(
        "SkillsBloc: AuthBloc current state before event: ${authBloc.state.runtimeType}",
      );

      authBloc.add(const AuthFinalizeSignUp());
      logger.i("SkillsBloc: AuthFinalizeSignUp event added to AuthBloc.");

      // Wait a moment and check state again
      await Future.delayed(Duration(milliseconds: 100));
      logger.i(
        "SkillsBloc: AuthBloc state after event: ${authBloc.state.runtimeType}",
      );
    } catch (e, s) {
      logger.e("SkillsBloc: Final submission failed.", error: e, stackTrace: s);
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: "Failed to finalize sign-up. Try again.",
        ),
      );
    }
  }
}
