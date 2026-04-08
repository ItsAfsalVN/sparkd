import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class CustomMessageBox extends StatelessWidget {
  final bool? disabled;
  final VoidCallback onAttachPressed;
  final TextEditingController? controller;

  const CustomMessageBox({
    super.key,
    this.controller,
    required this.onAttachPressed,
    this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return TextFormField(
      enabled: disabled != true,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: onAttachPressed,
          icon: Icon(
            Icons.attach_file_rounded,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: "Message",
        hintStyle: textStyles.subtext.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
      ),
    );
  }
}
