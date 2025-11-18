import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback? onPressed;
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
