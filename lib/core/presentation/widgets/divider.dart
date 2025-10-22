import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class LabeledDivider extends StatelessWidget {
  final String label;

  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textStyles.subtext;
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;

    return Row(
      spacing: 6,
      children: [
        Expanded(
          child: Divider(
            color: isLight ? AppColors.white300 : AppColors.black500,
            thickness: 1,
          ),
        ),
        Text(
          label,
          style: textStyle.copyWith(
            color: isLight ? AppColors.white300 : AppColors.black500,
          ),
        ),
        Expanded(
          child: Divider(
            color: isLight ? AppColors.white300 : AppColors.black500,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
