import 'package:flutter/material.dart';

class SmeDashboard extends StatelessWidget {
  const SmeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SME Dashboard')),
      body: const Center(child: Text('Welcome to the SME Dashboard!')),
    );
  }
}
