import 'package:flutter/material.dart';

class UiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const UiCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: .1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(padding: EdgeInsets.all(12), child: child),
    );
  }
}
