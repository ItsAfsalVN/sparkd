import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sparkd/core/utils/app_colors.dart';
// Import your theme extensions
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class OtpInput extends StatelessWidget {
  final TextInputType keyboardType;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  const OtpInput({
    super.key,
    this.keyboardType = TextInputType.number,
    this.autoFocus = false,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;

    // BorderColor
    final Color borderColor = isLight ? AppColors.white200 : AppColors.black600;

    final boxDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor, width: 1),
    );

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: textStyles.heading2.copyWith(
        color: colorScheme.primary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      decoration: boxDecoration,
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: boxDecoration.copyWith(
        border: Border.all(color: colorScheme.primary, width: 1),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: boxDecoration.copyWith(
        border: Border.all(color: borderColor, width: 1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: boxDecoration.copyWith(
        border: Border.all(color: colorScheme.error, width: 2),
      ),
    );

    return Pinput(
      controller: controller,
      length: 6,
      autofocus: autoFocus,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onCompleted: onCompleted,
      validator: validator,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,

      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 9),
            width: 22,
            height: 2,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
