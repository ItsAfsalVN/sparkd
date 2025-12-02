import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class CustomSearchBox extends StatelessWidget {
  final String hintText;
  const CustomSearchBox({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return TextFormField(
      decoration: InputDecoration(
        hint: Text(
          hintText,
          style: textStyles.paragraph.copyWith(
            color: colorScheme.onSurface.withValues(alpha: .5),
          ),
        ),
        suffixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurface.withValues(alpha: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: .4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
      ),
    );
  }
}
