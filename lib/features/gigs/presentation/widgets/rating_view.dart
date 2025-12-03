import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sparkd/core/utils/app_colors.dart';

class RatingView extends StatelessWidget {
  final double rating;
  const RatingView({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      itemBuilder: (context, index) {
        return const Icon(Icons.star_rounded, color: Colors.amber);
      },
      itemCount: 5,
      itemSize: 24.0,
      rating: rating,
      unratedColor: AppColors.black300,
    );
  }
}
