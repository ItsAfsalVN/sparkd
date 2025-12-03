import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';

class MandatoryRequirements extends StatefulWidget {
  final String? label;
  final List<RequirementEntity> requirements;
  final Function(List<RequirementEntity>) onChanged;
  final bool isRequired;
  final int maxRequirements;
  final String hintText;

  const MandatoryRequirements({
    super.key,
    this.label,
    this.requirements = const [],
    required this.onChanged,
    this.isRequired = true,
    this.maxRequirements = 10,
    this.hintText = "e.g., Company logo, Brand guidelines, Product images",
  });

  @override
  State<MandatoryRequirements> createState() => _MandatoryRequirementsState();
}

class _MandatoryRequirementsState extends State<MandatoryRequirements> {
  late List<RequirementEntity> _requirements;
  final TextEditingController _textController = TextEditingController();
  RequirementType _selectedType = RequirementType.text;

  @override
  void initState() {
    super.initState();
    _requirements = List.from(widget.requirements);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addRequirement() {
    final String description = _textController.text.trim();
    if (description.isEmpty) return;

    if (_requirements.length >= widget.maxRequirements) {
      _showMaxRequirementsSnackBar();
      return;
    }

    if (_requirements.any((r) => r.description == description)) {
      _showDuplicateSnackBar();
      return;
    }

    setState(() {
      _requirements.add(
        RequirementEntity(description: description, type: _selectedType),
      );
      _textController.clear();
    });

    widget.onChanged(_requirements);
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
    });
    widget.onChanged(_requirements);
  }

  void _showMaxRequirementsSnackBar() {
    showSnackbar(
      context,
      "Maximum \${widget.maxRequirements} requirements allowed",
      SnackBarType.info,
    );
  }

  void _showDuplicateSnackBar() {
    showSnackbar(
      context,
      "This requirement already exists",
      SnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        if (widget.label != null)
          Row(
            children: [
              Text(
                widget.label!,
                style: textStyles.subtext.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: .5),
                ),
              ),
              if (widget.isRequired)
                Text(
                  " *",
                  style: textStyles.heading5.copyWith(color: Colors.red),
                ),
            ],
          ),
        Row(
          children: [
            Text(
              "Type:",
              style: textStyles.paragraph.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<RequirementType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Text",
                        style: textStyles.paragraph.copyWith(fontSize: 14),
                      ),
                      value: RequirementType.text,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<RequirementType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "File",
                        style: textStyles.paragraph.copyWith(fontSize: 14),
                      ),
                      value: RequirementType.file,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: textStyles.paragraph.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: textStyles.paragraph,
                onSubmitted: (_) => _addRequirement(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addRequirement,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Add"),
            ),
          ],
        ),
        Text(
          "Specify if clients need to provide text information or upload files.",
          style: textStyles.paragraph.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w200,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        if (_requirements.isNotEmpty) ...[
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _requirements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final requirement = _requirements[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        requirement.type == RequirementType.text
                            ? Icons.text_fields
                            : Icons.attach_file,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              requirement.description,
                              style: textStyles.paragraph.copyWith(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              requirement.type == RequirementType.text
                                  ? "Text input"
                                  : "File upload",
                              style: textStyles.paragraph.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeRequirement(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        if (_requirements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isRequired
                    ? Colors.red.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 32,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                if (widget.isRequired)
                  Text(
                    "At least one requirement is mandatory",
                    style: textStyles.paragraph.copyWith(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_requirements.length} of ${widget.maxRequirements} requirements",
              style: textStyles.paragraph.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (widget.isRequired && _requirements.isEmpty)
              Text(
                "Required",
                style: textStyles.paragraph.copyWith(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
