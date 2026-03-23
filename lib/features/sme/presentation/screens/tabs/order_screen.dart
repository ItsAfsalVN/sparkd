import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class SmeOrdersScreen extends StatelessWidget {
  const SmeOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders', style: textStyles.heading2),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0.0,
      ),
      body: const Center(child: Text('This is the Order Screen')),
    );
  }
}
