import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/delivery_types.dart';

class DeliveryTypeSelector extends StatelessWidget {
  final String? label;
  final DeliveryTypes? selectedType;
  final Function(DeliveryTypes?) onChanged;
  final bool isRequired;

  const DeliveryTypeSelector({
    super.key,
    this.label,
    this.selectedType,
    required this.onChanged,
    this.isRequired = true,
  });

  String _getDeliveryTypeTitle(DeliveryTypes type) {
    switch (type) {
      case DeliveryTypes.file:
        return "File Delivery";
      case DeliveryTypes.serviceCompletion:
        return "Service Completion";
    }
  }

  String _getDeliveryTypeDescription(DeliveryTypes type) {
    switch (type) {
      case DeliveryTypes.file:
        return "Deliver tangible files (designs, documents, code, etc.) that the client will receive and own.";
      case DeliveryTypes.serviceCompletion:
        return "Complete a service or task (consultation, setup, maintenance, etc.) without file deliverables.";
    }
  }

  IconData _getDeliveryTypeIcon(DeliveryTypes type) {
    switch (type) {
      case DeliveryTypes.file:
        return Icons.folder_outlined;
      case DeliveryTypes.serviceCompletion:
        return Icons.handyman_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        // Label with required indicator
        if (label != null)
          Row(
            children: [
              Text(
                label!,
                style: textStyles.subtext.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: textStyles.heading5.copyWith(color: Colors.red),
                ),
            ],
          ),

        // Description
        Text(
          "Choose how you will deliver the final result to your client. This affects payment terms and completion criteria.",
          style: textStyles.paragraph.copyWith(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),

        // Delivery type options
        Column(
          spacing: 12,
          children: DeliveryTypes.values.map((type) {
            final isSelected = selectedType == type;

            return GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getDeliveryTypeIcon(type),
                        size: 24,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            _getDeliveryTypeTitle(type),
                            style: textStyles.heading5.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _getDeliveryTypeDescription(type),
                            style: textStyles.paragraph.copyWith(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 12,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Validation message
        if (isRequired && selectedType == null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "Please select a delivery type",
                  style: textStyles.paragraph.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Helper text
        if (selectedType != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedType == DeliveryTypes.file
                        ? "Your gig will be marked complete when files are delivered and approved."
                        : "Your gig will be marked complete when the service is performed and confirmed.",
                    style: textStyles.paragraph.copyWith(
                      fontSize: 12,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
