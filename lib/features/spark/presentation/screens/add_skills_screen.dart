import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/selectable_list.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/services/service_locator.dart' as di;
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:sparkd/features/spark/presentation/bloc/skills_bloc.dart';

class AddSkillsScreen extends StatelessWidget {
  const AddSkillsScreen({super.key});

  List<Widget> _mapCategoriesToChips(BuildContext context, SkillsState state) {
    return state.availableSkills.map((category) {
      final isSelected = state.isCategorySelected(category.categoryID);

      return SelectableChip(
        label: category.categoryName,
        value: category.categoryID,
        isSelected: isSelected,
        onTap: () {
          context.read<SkillsBloc>().add(
            CategoryToggled(categoryID: category.categoryID),
          );
        },
      );
    }).toList();
  }

  List<Widget> _buildToolSections(BuildContext context, SkillsState state) {
    final selectedCategoryIds = state.selectedSkills
        .map((skill) => skill.categoryID)
        .toList();

    return selectedCategoryIds.map((categoryId) {
      final category = state.availableSkills.firstWhere(
        (s) => s.categoryID == categoryId,
      );

      final toolChips = category.tools.map((tool) {
        final isSelected = state.isToolSelected(categoryId, tool.toolID);

        return SelectableChip(
          label: tool.toolName,
          value: tool.toolID,
          isSelected: isSelected,
          onTap: () {
            context.read<SkillsBloc>().add(
              ToolToggled(toolID: tool.toolID, categoryID: categoryId),
            );
          },
        );
      }).toList();

      return SelectableList(
        label: "${category.categoryName} Tools",
        children: toolChips,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final logo = isLight
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';
    final textStyles = Theme.of(context).textStyles;
    final colors = context.colors;

    return BlocProvider(
      create: (context) =>
          SkillsBloc(signUpDataRepository: di.sl(), staticDataSource: di.sl())
            ..add(SkillsLoadRequested()),

      child: BlocListener<SkillsBloc, SkillsState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == FormStatus.failure &&
              state.errorMessage != null) {
            logger.e("SkillsBloc Error: ${state.errorMessage}");
            showSnackbar(context, state.errorMessage!, SnackBarType.error);
          }
          if (state.status == FormStatus.success) {
            logger.i("Skills saved successfully. Sign-up finalized.");
            showSnackbar(
              context,
              "Skills saved! Sign-up complete.",
              SnackBarType.success,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                // FIXED: Use pushReplacement to go back to PhoneInputScreen
                // This maintains the signup flow and prevents black screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PhoneInputScreen(),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back_outlined),
            ),
            title: Image.asset(
              logo,
              width: 105,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BODY ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 24,
                          children: [
                            // Title and Description
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  "What\ndo you do?",
                                  style: textStyles.heading2.copyWith(
                                    height: 1.2,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  "Select the categories and tools you work with. This helps us customize your experience.",
                                  style: textStyles.paragraph.copyWith(
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            BlocBuilder<SkillsBloc, SkillsState>(
                              buildWhen: (prev, curr) =>
                                  prev.status != curr.status ||
                                  prev.focusedCategoryID !=
                                      curr.focusedCategoryID ||
                                  prev.selectedSkills != curr.selectedSkills ||
                                  prev.availableSkills != curr.availableSkills,
                              builder: (context, state) {
                                // Only show loading for initial load, not validation errors
                                if (state.status == FormStatus.loading ||
                                    state.status == FormStatus.initial) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                // Only show error if skills failed to load (empty available skills)
                                if (state.status == FormStatus.failure &&
                                    state.availableSkills.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "Error loading skills: ${state.errorMessage}",
                                    ),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 24,
                                  children: [
                                    SelectableList(
                                      label: "Categories",
                                      children: _mapCategoriesToChips(
                                        context,
                                        state,
                                      ),
                                    ),

                                    // FIX: Show tools for ALL selected categories
                                    ..._buildToolSections(context, state),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  BlocBuilder<SkillsBloc, SkillsState>(
                    buildWhen: (prev, curr) =>
                        prev.status != curr.status ||
                        prev.selectedSkills.length !=
                            curr.selectedSkills.length,
                    builder: (context, state) {
                      final isValid =
                          state.selectedSkills.isNotEmpty &&
                          state.status != FormStatus.loading;

                      if (state.status == FormStatus.submitting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return CustomButton(
                        onPressed: isValid
                            ? () {
                                context.read<SkillsBloc>().add(
                                  SkillsSubmitted(),
                                );
                              }
                            : null,
                        title: "Complete Sign up",
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
