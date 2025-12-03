import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/presentation/widgets/rating_view.dart';
import 'package:sparkd/core/presentation/widgets/ui_card.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/sme/presentation/screens/sme_gig_details_screen.dart';

class SmeGigCard extends StatelessWidget {
  final GigEntity gig;
  const SmeGigCard({super.key, required this.gig});

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
            child: gig.thumbnailImage != null
                ? Image.network(
                    gig.thumbnailImage!,
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
            gig.title,
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
                    gig.price.toStringAsFixed(0),
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
                  RatingView(rating: gig.rating),
                ],
              ),
            ],
          ),

          // Delivery Time and Created by
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
                    "${gig.deliveryTimeInDays} days",
                    style: textStyles.heading4.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: .6),
                    ),
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
                  if (gig.creatorId != null)
                    FutureBuilder<String?>(
                      future: UserHelper.getUserName(gig.creatorId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        return Text(
                          snapshot.data ?? "Unknown",
                          style: textStyles.heading4.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: .6),
                          ),
                        );
                      },
                    )
                  else
                    Text("Unknown", style: textStyles.heading4),
                ],
              ),
            ],
          ),
          // Button
          CustomButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SmeGigDetailsScreen(gig: gig),
                ),
              );
            },
            title: "Buy",
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}
