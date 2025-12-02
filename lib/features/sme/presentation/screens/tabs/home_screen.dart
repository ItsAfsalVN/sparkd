import 'package:flutter/material.dart';

class SmeHomeScreen extends StatelessWidget {
  const SmeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0.0,
      ),
      body: const Center(child: Text('Welcome to the Home Screen!')),
    );
  }
}
