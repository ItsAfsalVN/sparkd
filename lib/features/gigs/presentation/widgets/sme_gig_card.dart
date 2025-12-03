import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/features/gigs/presentation/widgets/rating_view.dart';
import 'package:sparkd/core/presentation/widgets/ui_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class SmeGigCard extends StatelessWidget {
  final String? thumbnailImage;
  final String? title;
  final double? price;
  final int? deliveryTimeInDays;
  final String? broughtBy;
  const SmeGigCard({
    super.key,
    this.thumbnailImage,
    this.title,
    this.price,
    this.deliveryTimeInDays,
    this.broughtBy,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;
    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: thumbnailImage != null
                ? Image.network(
                    thumbnailImage!,
                    fit: BoxFit.cover,
                    height: 160,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),

          // Title
          Text(
            title ?? "Instagram Reels Video Editing (3-Pack)",
            style: textStyles.heading4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Price and Ratings Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    "assets/icons/rupee.svg",
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface.withValues(alpha: .8),
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    "${price?.toStringAsFixed(0) ?? 2000}",
                    style: textStyles.heading2.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .8),
                      height: 1,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ratings",
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .3),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const RatingView(rating: 2.5),
                ],
              ),
            ],
          ),

          // Delivery Time and Brought by
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery Time",
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .3),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "${deliveryTimeInDays ?? 0} days",
                    style: textStyles.heading4,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Brought by",
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .3),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(broughtBy ?? "Unknown", style: textStyles.heading4),
                ],
              ),
            ],
          ),
          // Button
          CustomButton(
            onPressed: () {},
            title: "Buy",
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}
