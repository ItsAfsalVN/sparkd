import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';

class DeliverablesChecklist extends StatefulWidget {
  final String? label;
  final List<String> selectedDeliverables;
  final Function(List<String>) onChanged;
  final List<String>? customOptions;
  final int? maxSelections;

  const DeliverablesChecklist({
    super.key,
    this.label,
    this.selectedDeliverables = const [],
    required this.onChanged,
    this.customOptions,
    this.maxSelections,
  });

  @override
  State<DeliverablesChecklist> createState() => _DeliverablesChecklistState();
}

class _DeliverablesChecklistState extends State<DeliverablesChecklist> {
  late List<String> _selectedItems;

  // Default deliverables options - can be customized via customOptions
  static const List<String> _defaultDeliverables = [
    "High-Resolution Files",
    "Source Files",
    "Commercial License",
    "Multiple Revisions",
    "Fast Delivery",
    "24/7 Support",
    "Copyright Transfer",
    "Print-Ready Files",
    "Web-Optimized Files",
    "Style Guide",
    "Video Tutorial",
    "Raw Footage",
  ];

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedDeliverables);
  }

  List<String> get _availableOptions =>
      widget.customOptions ?? _defaultDeliverables;

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        // Check max selections limit
        if (widget.maxSelections == null ||
            _selectedItems.length < widget.maxSelections!) {
          _selectedItems.add(item);
        } else {
          _showMaxSelectionsSnackBar();
          return;
        }
      }
    });
    widget.onChanged(_selectedItems);
  }

  void _showMaxSelectionsSnackBar() {
    if (mounted) {
      showSnackbar(context, 'You can select a maximum of ${widget.maxSelections} deliverables', SnackBarType.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        // Label
        if (widget.label != null)
          Text(
            widget.label!,
            style: textStyles.heading5.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

        // Checkboxes container
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _availableOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _selectedItems.contains(item);
              final isLast = index == _availableOptions.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleItem(item),
                      borderRadius: BorderRadius.vertical(
                        top: index == 0
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottom: isLast
                            ? const Radius.circular(12)
                            : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Custom checkbox
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline.withValues(
                                          alpha: 0.6,
                                        ),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Deliverable text
                            Expanded(
                              child: Text(
                                item,
                                style: textStyles.paragraph.copyWith(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),

                            // Selected indicator
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Divider (except for last item)
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      indent: 48,
                    ),
                ],
              );
            }).toList(),
          ),
        ),

        // Helper text
        if (widget.maxSelections != null || _selectedItems.isNotEmpty)
          Row(
            children: [
              if (widget.maxSelections != null) ...[
                Text(
                  "Max ${widget.maxSelections} selections",
                  style: textStyles.paragraph.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (_selectedItems.isNotEmpty) const SizedBox(width: 8),
              ],
              if (_selectedItems.isNotEmpty)
                Text(
                  "• ${_selectedItems.length} deliverable${_selectedItems.length == 1 ? '' : 's'} promised",
                  style: textStyles.paragraph.copyWith(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
