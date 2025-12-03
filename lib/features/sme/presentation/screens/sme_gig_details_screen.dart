import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/gigs/presentation/widgets/rating_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:logger/logger.dart';

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
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;
  String? _videoError;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeYoutubeController();
    _buildMediaItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeYoutubeController() {
    logger.i('_initializeYoutubeController called');
    logger.i('Demo video URL: ${widget.gig.demoVideo}');

    if (widget.gig.demoVideo != null && widget.gig.demoVideo!.isNotEmpty) {
      final youtubeVideoId = YoutubePlayer.convertUrlToId(
        widget.gig.demoVideo!,
      );

      logger.i('YouTube video ID: $youtubeVideoId');

      if (youtubeVideoId != null) {
        logger.i('Initializing YouTube controller');
        _youtubeController = YoutubePlayerController(
          initialVideoId: youtubeVideoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      } else {
        // It's an uploaded video file
        logger.i('Not a YouTube URL, initializing video player');
        _initializeVideoPlayer(widget.gig.demoVideo!);
      }
    } else {
      logger.w('Demo video is null or empty');
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    if (!mounted) return;

    setState(() {
      _isVideoLoading = true;
      _videoError = null;
    });

    try {
      logger.i('Initializing video player with URL: $videoUrl');

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.hasError) {
          logger.e(
            'Video player error: ${_videoPlayerController!.value.errorDescription}',
          );
          if (mounted) {
            setState(() {
              _videoError = _videoPlayerController!.value.errorDescription;
              _isVideoLoading = false;
            });
          }
        }
      });

      // Add timeout to prevent infinite loading
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Video loading timeout - please check your internet connection',
          );
        },
      );

      logger.i(
        'Video initialized successfully. Duration: ${_videoPlayerController!.value.duration}',
      );
      logger.i('Video size: ${_videoPlayerController!.value.size}');

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        showControlsOnInitialize: false,
        allowFullScreen: false,
        allowMuting: false,
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, errorMessage) {
          logger.e('Chewie error: $errorMessage');
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading video',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          // Rebuild media items now that video is ready
          _buildMediaItems();
        });
      }
    } catch (e) {
      logger.e('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _videoError = e.toString();
          _isVideoLoading = false;
          // Rebuild media items to show error
          _buildMediaItems();
        });
      }
    }
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
    // Check if it's a YouTube URL and we have a controller
    if (_youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      );
    }

    // Show error if video failed to load
    if (_videoError != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _videoError!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if it's an uploaded video file
    if (_chewieController != null && _videoPlayerController != null) {
      if (_videoPlayerController!.value.isInitialized) {
        return Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController!.value.size.width,
                  height: _videoPlayerController!.value.size.height,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
              // Custom play/pause overlay
              _CustomVideoControls(
                videoPlayerController: _videoPlayerController!,
              ),
            ],
          ),
        );
      }
    }

    // Loading state
    if (_isVideoLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading video...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    // Fallback: show a placeholder
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text('Video not available', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
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
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _mediaItems.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRect(child: _mediaItems[index]);
                    },
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

class _CustomVideoControls extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const _CustomVideoControls({required this.videoPlayerController});

  @override
  State<_CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<_CustomVideoControls> {
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Center play/pause button
            if (_showControls || !widget.videoPlayerController.value.isPlaying)
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (widget.videoPlayerController.value.isPlaying) {
                        widget.videoPlayerController.pause();
                      } else {
                        widget.videoPlayerController.play();
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      widget.videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            // Progress bar at bottom
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: VideoProgressIndicator(
                    widget.videoPlayerController,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Theme.of(context).primaryColor,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
