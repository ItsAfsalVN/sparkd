import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_colors.dart';

class AppColorThemeExtension extends ThemeExtension<AppColorThemeExtension> {

  final Color brand;
  final Color secondary;
  final Color secondaryDark;
  final Color accent;
  final Color accentDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color background;
  final Color card;
  final Color border;

  const AppColorThemeExtension({
    required this.brand,
    required this.secondary,
    required this.secondaryDark,
    required this.accent,
    required this.accentDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.background,
    required this.card,
    required this.border,
  });

  @override
  ThemeExtension<AppColorThemeExtension> copyWith({
    Color? brand,
    Color? secondary,
    Color? secondaryDark,
    Color? accent,
    Color? accentDark,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? background,
    Color? card,
    Color? border,
  }) {
    return AppColorThemeExtension(
      brand: brand ?? this.brand,
      secondary: secondary ?? this.secondary,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      background: background ?? this.background,
      card: card ?? this.card,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<AppColorThemeExtension> lerp(
    covariant ThemeExtension<AppColorThemeExtension>? other,
    double t,
  ) {
    if (other is! AppColorThemeExtension) {
      return this;
    }
    return AppColorThemeExtension(
      brand: Color.lerp(brand, other.brand, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryDark: Color.lerp(secondaryDark, other.secondaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }

  static const AppColorThemeExtension light = AppColorThemeExtension(
    brand: AppColors.primary100,
    secondary: AppColors.secondary400,
    secondaryDark: AppColors.secondary500,
    accent: AppColors.accent300,
    accentDark: AppColors.accent400,
    textPrimary: AppColors.white700, 
    textSecondary: AppColors.white500,
    textDisabled: AppColors.white300,
    background: AppColors.white100, 
    card: AppColors.white,
    border: AppColors.white200,
  );

  static const AppColorThemeExtension dark = AppColorThemeExtension(
    brand: AppColors.primary100, 
    secondary: AppColors.secondary400,
    secondaryDark: AppColors.secondary500,
    accent: AppColors.accent300,
    accentDark: AppColors.accent400,
    textPrimary: AppColors.black100, 
    textSecondary: AppColors.black300,
    textDisabled: AppColors.black500,
    background: AppColors.white700, 
    card: AppColors.white600, 
    border: AppColors.white600,
  );
}

extension ThemeHelper on BuildContext {
  AppColorThemeExtension get colors =>
      Theme.of(this).extension<AppColorThemeExtension>()!;
}
