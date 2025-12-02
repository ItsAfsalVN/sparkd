import 'package:flutter/material.dart';

class SmeProfileScreen extends StatelessWidget {
  const SmeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0.0,
      ),
      body: const Center(child: Text('This is the Profile Screen')),
    );
  }
}
