import 'package:flutter/material.dart';

class SmeInboxScreen extends StatelessWidget {
  const SmeInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: const Center(
        child: Text('This is the Inbox Screen'),
      ),
    );
  }
}