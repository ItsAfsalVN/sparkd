import 'package:flutter/material.dart';
// Make sure this import points to your AppTextStyles file
import 'package:sparkd/core/utils/app_text_styles.dart';

class AppTextThemeExtension extends ThemeExtension<AppTextThemeExtension> {
  final TextStyle heading1;
  final TextStyle heading2;
  final TextStyle heading3;
  final TextStyle heading5;
  final TextStyle paragraph;
  final TextStyle subtext;

  const AppTextThemeExtension({
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.heading5,
    required this.paragraph,
    required this.subtext,
  });

  @override
  ThemeExtension<AppTextThemeExtension> copyWith({
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? heading5,
    TextStyle? paragraph,
    TextStyle? subtext,
  }) {
    return AppTextThemeExtension(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      heading5: heading5 ?? this.heading5,
      paragraph: paragraph ?? this.paragraph,
      subtext: subtext ?? this.subtext,
    );
  }

  @override
  ThemeExtension<AppTextThemeExtension> lerp(
    covariant ThemeExtension<AppTextThemeExtension>? other,
    double t,
  ) {
    if (other is! AppTextThemeExtension) {
      return this;
    }
    return AppTextThemeExtension(
      heading1: TextStyle.lerp(heading1, other.heading1, t)!,
      heading2: TextStyle.lerp(heading2, other.heading2, t)!,
      heading3: TextStyle.lerp(heading3, other.heading3, t)!,
      heading5: TextStyle.lerp(heading5, other.heading5, t)!,
      paragraph: TextStyle.lerp(paragraph, other.paragraph, t)!,
      subtext: TextStyle.lerp(subtext, other.subtext, t)!,
    );
  }

  static const AppTextThemeExtension main = AppTextThemeExtension(
    heading1: AppTextStyles.heading1,
    heading2: AppTextStyles.heading2,
    heading3: AppTextStyles.heading3,
    heading5: AppTextStyles.heading5,
    paragraph: AppTextStyles.paragraph,
    subtext: AppTextStyles.subtext,
  );
}

extension CustomTextThemeData on ThemeData {
  AppTextThemeExtension get textStyles => extension<AppTextThemeExtension>()!;
}
