import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class MarkAsCompletedDialog extends StatelessWidget {
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;
  final VoidCallback onConfirm;

  const MarkAsCompletedDialog({
    super.key,
    required this.colorScheme,
    required this.textStyles,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: colorScheme.error,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Text('Mark as Completed', style: textStyles.heading4),
                ),
              ],
            ),
            Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'Once you mark this order as completed:',
                    style: textStyles.paragraph.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CompletionWarningItem(
                    text: 'Messaging will be disabled permanently',
                    color: colorScheme.error,
                    colorScheme: colorScheme,
                    textStyles: textStyles,
                  ),
                  CompletionWarningItem(
                    text: 'You can still download files from this workshop',
                    color: colorScheme.primary,
                    colorScheme: colorScheme,
                    textStyles: textStyles,
                  ),
                  CompletionWarningItem(
                    text: 'The order will be marked as completed in the system',
                    color: colorScheme.primary,
                    colorScheme: colorScheme,
                    textStyles: textStyles,
                  ),
                ],
              ),
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Cancel', style: textStyles.heading5),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: textStyles.heading5.copyWith(
                        color: colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompletionWarningItem extends StatelessWidget {
  final String text;
  final Color color;
  final ColorScheme colorScheme;
  final AppTextThemeExtension textStyles;

  const CompletionWarningItem({
    super.key,
    required this.text,
    required this.color,
    required this.colorScheme,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(Icons.info_outline, size: 16, color: color),
        Expanded(
          child: Text(
            text,
            style: textStyles.paragraph.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
