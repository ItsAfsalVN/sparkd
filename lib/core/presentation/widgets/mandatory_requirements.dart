import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';

class MandatoryRequirements extends StatefulWidget {
  final String? label;
  final List<String> requirements;
  final Function(List<String>) onChanged;
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
  late List<String> _requirements;
  final TextEditingController _textController = TextEditingController();

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
    final String requirement = _textController.text.trim();
    if (requirement.isEmpty) return;

    if (_requirements.length >= widget.maxRequirements) {
      _showMaxRequirementsSnackBar();
      return;
    }

    if (_requirements.contains(requirement)) {
      _showDuplicateSnackBar();
      return;
    }

    setState(() {
      _requirements.add(requirement);
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
    showSnackbar(context, "Maximum ${widget.maxRequirements} requirements allowed", SnackBarType.info);
  }

  void _showDuplicateSnackBar() {
    showSnackbar(context, "This requirement already exists", SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Label with required indicator
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

        // Input field
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
        // Description
        Text(
          "List all client assets and materials required to start work on this gig. Be specific about formats, sizes, and deadlines.",
          style: textStyles.paragraph.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w200,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),

        // Requirements list
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
                        Icons.assignment_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          requirement,
                          style: textStyles.paragraph.copyWith(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
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

        // Empty state
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

        // Counter
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
