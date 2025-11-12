import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBottomNavigationBarItem {
  final String label;
  final String iconPath;
  final Widget screen;

  const AppBottomNavigationBarItem({
    required this.label,
    required this.iconPath,
    required this.screen,
  });

  BottomNavigationBarItem toBottomNavigationBarItem({
    required Color activeColor,
    required Color inactiveColor,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isSelected ? activeColor : inactiveColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
