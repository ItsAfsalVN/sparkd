import 'package:flutter/material.dart';

class SmeOrdersScreen extends StatelessWidget {
  const SmeOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: const Center(
        child: Text('This is the Order Screen'),
      ),
    );
  }
}