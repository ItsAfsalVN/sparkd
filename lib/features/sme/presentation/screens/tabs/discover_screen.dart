import 'package:flutter/material.dart';

class SmeDiscoverScreen extends StatelessWidget {
  const SmeDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: const Center(
        child: Text('This is the Discover Screen'),
      ),
    );
  }
}