import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/presentation/widgets/ui_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/spark/presentation/screens/edit_gig_screen.dart';

class SparkGigCard extends StatelessWidget {
  final String? title;
  final String? description;
  final double? price;
  final String? thumbnailImage;
  final String? category;

  const SparkGigCard({
    super.key,
    this.title,
    this.description,
    this.price,
    this.thumbnailImage,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              child: thumbnailImage != null
                  ? Image.network(
                      thumbnailImage!,
                      fit: BoxFit.cover,
                      height: 160,
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
          ),

          // Content Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title ?? "Untitled Gig",
                  style: textStyles.heading4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                spacing: 3,
                children: [
                  Icon(
                    Icons.remove_red_eye_rounded,
                    color: colorScheme.onSurface.withValues(alpha: .3),
                    size: 20,
                  ),
                  Text(
                    "1.2k",
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .3),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Earnings and Orders Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Earnings
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total earnings:",
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .3),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
                        "${price?.toStringAsFixed(0) ?? 0}",
                        style: textStyles.heading2.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: .8),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ), // Orders
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Orders in progress:",
                    style: textStyles.subtext.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .3),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "4",
                    style: textStyles.heading2.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .8),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),

          CustomButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => EditGigScreen()));
            },
            title: "Edit",
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}
