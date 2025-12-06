import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';

class TagInput extends StatefulWidget {
  final String? label;
  final String hintText;
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;
  final int? maxTags;
  final int? maxTagLength;
  final String? Function(String)? tagValidator;

  const TagInput({
    super.key,
    this.label,
    this.hintText = "Add a tag...",
    this.initialTags = const [],
    required this.onTagsChanged,
    this.maxTags,
    this.maxTagLength = 20,
    this.tagValidator,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tagText) {
    final trimmedTag = tagText.trim().toLowerCase();

    // Basic validation
    if (trimmedTag.isEmpty) return;
    if (_tags.contains(trimmedTag)) return;
    if (widget.maxTags != null && _tags.length >= widget.maxTags!) return;
    if (widget.maxTagLength != null && trimmedTag.length > widget.maxTagLength!) {
      return;
    }

    // Custom validation
    if (widget.tagValidator != null) {
      final error = widget.tagValidator!(trimmedTag);
      if (error != null) {
        _showErrorSnackBar(error);
        return;
      }
    }

    setState(() {
      _tags.add(trimmedTag);
    });

    widget.onTagsChanged(_tags);
    _controller.clear();
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
    widget.onTagsChanged(_tags);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      showSnackbar(context, message, SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Label
        if (widget.label != null)
          Text(
            widget.label!,
            style: textStyles.subtext.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

        // Tags display
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: textStyles.paragraph.copyWith(
                        fontSize: 14,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeTag(index),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        // Input field
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hint: Text(
                widget.hintText,
                style: textStyles.paragraph.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                onPressed: () => _addTag(_controller.text),
                icon: Icon(Icons.add, color: colorScheme.primary),
              ),
            ),
            style: textStyles.paragraph.copyWith(fontSize: 16),
            textInputAction: TextInputAction.done,
            onSubmitted: _addTag,
            onChanged: (value) {
              setState(() {}); // Rebuild to update suffix icon state
            },
          ),
        ),

        // Helper text
        Row(
          children: [
            Text(
              "${_tags.length}${widget.maxTags != null ? '/${widget.maxTags}' : ''} tags",
              style: textStyles.paragraph.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (widget.maxTagLength != null) ...[
              const SizedBox(width: 8),
              Text(
                "• Max ${widget.maxTagLength} characters per tag",
                style: textStyles.paragraph.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
