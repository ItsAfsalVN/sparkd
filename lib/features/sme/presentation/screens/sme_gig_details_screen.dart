import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/gigs/presentation/widgets/rating_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SmeGigDetailsScreen extends StatefulWidget {
  final GigEntity gig;

  const SmeGigDetailsScreen({super.key, required this.gig});

  @override
  State<SmeGigDetailsScreen> createState() => _SmeGigDetailsScreenState();
}

class _SmeGigDetailsScreenState extends State<SmeGigDetailsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<Widget> _mediaItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildMediaItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _buildMediaItems() {
    _mediaItems = [];

    // Add thumbnail
    if (widget.gig.thumbnailImage != null) {
      _mediaItems.add(_buildImageWidget(widget.gig.thumbnailImage!));
    }

    // Add portfolio images
    for (final image in widget.gig.portfolioImages) {
      _mediaItems.add(_buildImageWidget(image));
    }

    // Add demo video
    if (widget.gig.demoVideo != null && widget.gig.demoVideo!.isNotEmpty) {
      _mediaItems.add(_buildVideoWidget(widget.gig.demoVideo!));
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 50, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildVideoWidget(String videoUrl) {
    // Check if it's a YouTube URL
    final youtubeVideoId = YoutubePlayer.convertUrlToId(videoUrl);

    if (youtubeVideoId != null) {
      return YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: youtubeVideoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        ),
        showVideoProgressIndicator: true,
      );
    }

    // For other video URLs or uploaded videos, show a play icon overlay
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.black,
          child: const Icon(
            Icons.play_circle_outline,
            size: 80,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            'Video Demo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: _mediaItems,
                  ),
                  if (_mediaItems.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _mediaItems.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.gig.title, style: textStyles.heading3),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        widget.gig.description,
                        style: textStyles.paragraph.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  // Price and Ratings Section
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        spacing: 12,
                        children: [
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
                                      colorScheme.onSurface.withValues(
                                        alpha: .8,
                                      ),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  Text(
                                    widget.gig.price.toStringAsFixed(0),
                                    style: textStyles.heading2.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .8,
                                      ),
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
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .3,
                                      ),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  RatingView(rating: widget.gig.rating),
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
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .3,
                                      ),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    "${widget.gig.deliveryTimeInDays} days",
                                    style: textStyles.heading4.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Creator",
                                    style: textStyles.subtext.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .3,
                                      ),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (widget.gig.creatorId != null)
                                    FutureBuilder<String?>(
                                      future: UserHelper.getUserName(
                                        widget.gig.creatorId!,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    colorScheme.primary,
                                                  ),
                                            ),
                                          );
                                        }
                                        return Text(
                                          snapshot.data ?? "Unknown",
                                          style: textStyles.heading4.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: .6),
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Requirements",
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: .3,
                              ),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          ...widget.gig.requirements.map((requirement) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  requirement.type == RequirementType.text
                                      ? Icons.text_fields
                                      : Icons.attach_file,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    requirement.description,
                                    style: textStyles.paragraph.copyWith(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        spacing: 8,
                        children: [
                          Text(
                            "Max revisions:",
                            style: textStyles.subtext.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: .3,
                              ),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.gig.maxRevisions.toString(),
                            style: textStyles.heading4.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: .6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CustomButton(
            onPressed: () {},
            title: "Continue to Requirements",
          ),
        ),
      ),
    );
  }
}
