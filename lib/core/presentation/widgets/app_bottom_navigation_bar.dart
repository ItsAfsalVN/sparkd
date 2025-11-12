import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/app_bottom_navigation_bar_item.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final List<AppBottomNavigationBarItem> items;

  const AppBottomNavigationBar({
    super.key,
    required this.items,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.onSurface.withValues(alpha: .3);

    return BottomNavigationBar(
      items: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return item.toBottomNavigationBarItem(
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          isSelected: selectedIndex == index,
        );
      }).toList(),
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      backgroundColor: colorScheme.surface,
      selectedLabelStyle: textStyles?.subtext.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      unselectedLabelStyle: textStyles?.subtext.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 11,
      ),
      showUnselectedLabels: true,
      elevation: 8,
    );
  }
}
