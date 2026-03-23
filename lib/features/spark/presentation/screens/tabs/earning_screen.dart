import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class SparkEarningScreen extends StatelessWidget {
  const SparkEarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    return Scaffold(
      appBar: AppBar(title: Text("Earnings", style: textStyles.heading2)),
      body: Center(child: Text("Earning screen")),
    );
  }
}
