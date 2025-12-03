import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_color_theme_extension.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/app_colors.dart';

class SelectableChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectableChip({
    super.key,
    required this.label,
    required this.value,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final Color backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 1,
              spreadRadius: 0,
              color: context.colors.textPrimary.withValues(alpha: .2),
            ),
            BoxShadow(
              offset: Offset(0, -1),
              blurRadius: 1,
              spreadRadius: 0,
              color: context.colors.background.withValues(alpha: .2),
            ),
          ],
        ),
        child: Text(
          label,
          style: textStyles.paragraph.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class SelectableList extends StatelessWidget {
  final String? label;
  final List<Widget>? children;

  const SelectableList({super.key, this.label, this.children});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;

    List<Widget> content = [];

    if (label != null) {
      content.add(
        Text(
          label!,
          style: textStyles.heading5.copyWith(color: AppColors.white400),
        ),
      );
    }

    content.add(Wrap(spacing: 8.0, runSpacing: 8.0, children: children ?? []));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: content,
    );
  }
}
