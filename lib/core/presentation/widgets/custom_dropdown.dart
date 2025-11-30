import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final T? value;
  final List<DropdownItem<T>> items;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final FocusNode? focusNode;

  const CustomDropdown({
    super.key,
    this.label,
    required this.hintText,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        // Label
        if (label != null)
          Text(
            label!,
            style: textStyles.heading5.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

        // Dropdown
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            focusNode: focusNode,
            initialValue: value,
            hint: Text(
              hintText,
              style: textStyles.subtext.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                fontSize: 14,
              ),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: textStyles.paragraph.copyWith(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
            dropdownColor: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item.value,
                child: Text(
                  item.label,
                  style: textStyles.paragraph.copyWith(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
            icon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({required this.value, required this.label});
}

// Predefined dropdown items for delivery time
class DeliveryTimeDropdown extends StatelessWidget {
  final int? selectedDays;
  final Function(int?) onChanged;

  const DeliveryTimeDropdown({
    super.key,
    this.selectedDays,
    required this.onChanged,
  });

  static const List<DropdownItem<int>> deliveryOptions = [
    DropdownItem(value: 1, label: "1 Day"),
    DropdownItem(value: 2, label: "2 Days"),
    DropdownItem(value: 3, label: "3 Days"),
    DropdownItem(value: 5, label: "5 Days"),
    DropdownItem(value: 7, label: "1 Week"),
    DropdownItem(value: 14, label: "2 Weeks"),
    DropdownItem(value: 21, label: "3 Weeks"),
    DropdownItem(value: 30, label: "1 Month"),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<int>(
      label: "Delivery Time",
      hintText: "Select delivery time",
      value: selectedDays,
      items: deliveryOptions,
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return "Please select a delivery time";
        }
        return null;
      },
    );
  }
}

// Predefined dropdown items for revisions
class RevisionsDropdown extends StatelessWidget {
  final int? selectedRevisions;
  final Function(int?) onChanged;

  const RevisionsDropdown({
    super.key,
    this.selectedRevisions,
    required this.onChanged,
  });

  static const List<DropdownItem<int>> revisionOptions = [
    DropdownItem(value: 0, label: "No Revisions"),
    DropdownItem(value: 1, label: "1 Revision"),
    DropdownItem(value: 2, label: "2 Revisions"),
    DropdownItem(value: 3, label: "3 Revisions"),
    DropdownItem(value: 5, label: "5 Revisions"),
    DropdownItem(value: -1, label: "Unlimited Revisions"),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<int>(
      label: "Revisions",
      hintText: "Select number of revisions",
      value: selectedRevisions,
      items: revisionOptions,
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return "Please select number of revisions";
        }
        return null;
      },
    );
  }
}

class BusinessCategoryDropdown extends StatelessWidget {
  final Function(String?) onChanged;
  final FocusNode? focusNode;

  const BusinessCategoryDropdown({super.key, required this.onChanged, this.focusNode});

  // Business categories
  static const List<DropdownItem<String>> businessCategories = [
    DropdownItem(value: 'food_restaurant', label: 'Food & Restaurant'),
    DropdownItem(value: 'retail_fashion', label: 'Retail & Fashion'),
    DropdownItem(value: 'health_wellness', label: 'Health & Wellness'),
    DropdownItem(value: 'beauty_salon', label: 'Beauty & Salon'),
    DropdownItem(value: 'education_training', label: 'Education & Training'),
    DropdownItem(
      value: 'professional_services',
      label: 'Professional Services',
    ),
    DropdownItem(value: 'home_services', label: 'Home Services'),
    DropdownItem(value: 'automotive', label: 'Automotive'),
    DropdownItem(value: 'real_estate', label: 'Real Estate'),
    DropdownItem(value: 'entertainment', label: 'Entertainment & Events'),
    DropdownItem(value: 'technology', label: 'Technology'),
    DropdownItem(value: 'hospitality', label: 'Hospitality & Tourism'),
    DropdownItem(value: 'other', label: 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      focusNode: focusNode,
      label: "Business Category",
      hintText: "Select your business category",
      value: null,
      items: businessCategories,
      onChanged: (value) {
        onChanged(value);
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a business category';
        }
        return null;
      },
    );
  }
}
