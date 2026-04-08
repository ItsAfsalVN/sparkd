import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/file_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';

class RequirementsTabWidget extends StatelessWidget {
  final List<RequirementEntity> requirements;
  final Map<String, dynamic> requirementResponses;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const RequirementsTabWidget({
    super.key,
    required this.requirements,
    required this.requirementResponses,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            Text(
              'No requirements',
              style: textStyles.paragraph.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text('Order Requirements', style: textStyles.heading4),
              Text(
                'SME responses to requirements',
                style: textStyles.subtext.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          ...requirements.map((requirement) {
            return RequirementItemWidget(
              requirement: requirement,
              responseData: requirementResponses[requirement.description],
              colorScheme: colorScheme,
              textStyles: textStyles,
            );
          }),
        ],
      ),
    );
  }
}

class RequirementItemWidget extends StatelessWidget {
  final RequirementEntity requirement;
  final dynamic responseData;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const RequirementItemWidget({
    super.key,
    required this.requirement,
    required this.responseData,
    required this.colorScheme,
    required this.textStyles,
  });

  String? _extractResponseValue() {
    if (responseData == null) return null;
    if (responseData is! Map) return null;

    if (requirement.type.name == 'text') {
      return responseData['value'] as String?;
    } else if (requirement.type.name == 'file') {
      return responseData['url'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final responseValue = _extractResponseValue();
    final hasResponse = responseValue != null && responseValue.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  requirement.type.name.toUpperCase(),
                  style: textStyles.subtext.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  requirement.description,
                  style: textStyles.paragraph.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          if (hasResponse)
            requirement.type.name == 'text'
                ? TextResponseWidget(
                    responseValue: responseValue,
                    colorScheme: colorScheme,
                    textStyles: textStyles,
                  )
                : FileResponseWidget(
                    fileUrl: responseValue,
                    colorScheme: colorScheme,
                    textStyles: textStyles,
                  )
          else
            NoResponseWidget(colorScheme: colorScheme, textStyles: textStyles),
        ],
      ),
    );
  }
}

class TextResponseWidget extends StatelessWidget {
  final String responseValue;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const TextResponseWidget({
    super.key,
    required this.responseValue,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Text(
        responseValue,
        style: textStyles.paragraph.copyWith(
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class FileResponseWidget extends StatelessWidget {
  final String fileUrl;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const FileResponseWidget({
    super.key,
    required this.fileUrl,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 8,
            right: 12,
            top: 8,
            bottom: 40,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Icon(
                FileHelper.getFileIcon(fileUrl),
                color: colorScheme.onSurface,
              ),
              Flexible(
                child: Text(
                  FileHelper.getFileName(fileUrl),
                  overflow: TextOverflow.visible,
                  style: textStyles.paragraph.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 3,
          right: 3,
          child: BlocBuilder<WorkshopBloc, WorkshopState>(
            builder: (context, downloadState) {
              if (downloadState is WorkshopFileDownloadSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.check,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                );
              }
              return IconButton(
                onPressed: () {
                  context.read<WorkshopBloc>().add(
                    WorkshopDownloadFile(
                      fileUrl: fileUrl,
                      fileName: FileHelper.getFileName(fileUrl),
                    ),
                  );
                },
                icon: Icon(
                  Icons.download_rounded,
                  size: 24,
                  color: colorScheme.onSurface,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NoResponseWidget extends StatelessWidget {
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const NoResponseWidget({
    super.key,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(Icons.info_outlined, size: 18, color: colorScheme.error),
          Expanded(
            child: Text(
              'No response provided',
              style: textStyles.paragraph.copyWith(
                fontSize: 12,
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
