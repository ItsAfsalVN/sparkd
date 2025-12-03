import 'package:flutter/material.dart';

class SmeGigDetailsScreen extends StatelessWidget {
  const SmeGigDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SME Gig Details')),
      body: const Center(
        child: Text('Details of the SME Gig will be shown here.'),
      ),
    );
  }
}
