import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/selectable_list.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkd/features/auth/presentation/screens/decision_screen.dart';
import 'package:sparkd/features/auth/presentation/screens/phone_input_screen.dart';
import 'package:sparkd/features/spark/presentation/bloc/skills_bloc.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/spark_dashboard_screen.dart';
import '../../../../core/services/service_locator.dart' as di;
import 'package:sparkd/core/utils/form_statuses.dart';

class AddSkillsScreen extends StatefulWidget {
  const AddSkillsScreen({super.key});

  @override
  State<AddSkillsScreen> createState() => _AddSkillsScreenState();
}

class _AddSkillsScreenState extends State<AddSkillsScreen> {
  @override
  void initState() {
    super.initState();

    final authBloc = di.sl<AuthBloc>();
    logger.i(
      "AddSkillsScreen: AuthBloc instance hashCode: ${authBloc.hashCode}",
    );
    logger.i(
      "AddSkillsScreen: Initial AuthBloc state: ${authBloc.state.runtimeType}",
    );

    // Check if already authenticated when screen loads
    if (authBloc.state is AuthAuthenticated) {
      logger.i("AddSkillsScreen: Already authenticated in initState!");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SparkDashboardScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    final logo = isLight
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';
    final textStyles = Theme.of(context).textStyles;
    final colors = context.colors;

    final authBloc = di.sl<AuthBloc>();

    return BlocProvider(
      create: (context) =>
          SkillsBloc(signUpDataRepository: di.sl(), staticDataSource: di.sl())
            ..add(SkillsLoadRequested()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<SkillsBloc, SkillsState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == FormStatus.failure &&
                  state.errorMessage != null) {
                logger.e("SkillsBloc Error: ${state.errorMessage}");
                showSnackbar(context, state.errorMessage!, SnackBarType.error);
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            bloc: authBloc,
            listener: (context, state) {
              logger.i("AddSkillsScreen BlocListener triggered!");
              logger.i(
                "AddSkillsScreen: AuthBloc state changed to: ${state.runtimeType}",
              );

              if (state is AuthAuthenticated) {
                logger.i(
                  "AddSkillsScreen: Sign-up complete! Navigating to Spark dashboard...",
                );
                logger.i("AddSkillsScreen: UserType: ${state.userType}");

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SparkDashboardScreen()),
                  (route) => false,
                );
              } else if (state is AuthUnauthenticated) {
                logger.e("AddSkillsScreen: Sign-up failed, returning to start");
                showSnackbar(
                  context,
                  "Sign-up failed. Please try again.",
                  SnackBarType.error,
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DecisionScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        child: Scaffold(
          // ... rest of your UI
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PhoneInputScreen(),
                  ),
                );
              },
              icon: Icon(Icons.arrow_back_rounded),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 24,
                          children: [
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
                                if (state.status == FormStatus.loading ||
                                    state.status == FormStatus.initial) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

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
                          state.status != FormStatus.loading &&
                          state.status != FormStatus.submitting;
                      final isLoading = state.status == FormStatus.submitting;

                      return CustomButton(
                        onPressed: isValid && !isLoading
                            ? () {
                                context.read<SkillsBloc>().add(
                                  SkillsSubmitted(),
                                );
                              }
                            : null,
                        title: isLoading ? "Completing..." : "Complete Sign up",
                        isLoading: isLoading,
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

  List<Widget> _mapCategoriesToChips(BuildContext context, SkillsState state) {
    // ... your existing implementation
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
    // ... your existing implementation
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
}
