import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'dart:io';

class VideoUpload extends StatefulWidget {
  final String? label;
  final String hintText;
  final String? videoUrl;
  final Function(String?) onChanged;
  final bool isRequired;
  final bool allowUrlInput;

  const VideoUpload({
    super.key,
    this.label,
    this.hintText = "Upload a video",
    this.videoUrl,
    required this.onChanged,
    this.isRequired = false,
    this.allowUrlInput = true,
  });

  @override
  State<VideoUpload> createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.allowUrlInput ? 2 : 1,
      vsync: this,
    );
    if (widget.videoUrl != null) {
      _urlController.text = widget.videoUrl!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Pick video file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final String videoPath = result.files.single.path!;
        final File videoFile = File(videoPath);

        // Check file size (limit to 50MB)
        final int fileSize = await videoFile.length();
        const int maxSize = 50 * 1024 * 1024; // 50MB in bytes

        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Video file is too large. Please select a file under 50MB.",
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        widget.onChanged(videoPath);
        _urlController.text = videoPath;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Video selected successfully!"),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking video: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _updateUrl(String url) {
    widget.onChanged(url.trim().isEmpty ? null : url.trim());
  }

  void _removeVideo() {
    widget.onChanged(null);
    _urlController.clear();
  }

  bool get _hasVideo => widget.videoUrl != null && widget.videoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        // Label
        if (widget.label != null)
          Row(
            children: [
              Text(
                widget.label!,
                style: textStyles.subtext.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (widget.isRequired)
                Text(
                  " *",
                  style: textStyles.heading5.copyWith(color: Colors.red),
                ),
            ],
          ),

        // Tabs (if URL input is allowed)
        if (widget.allowUrlInput)
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: textStyles.paragraph.copyWith(fontSize: 14),
              unselectedLabelStyle: textStyles.paragraph.copyWith(fontSize: 14),
              unselectedLabelColor: colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              tabs: const [
                Tab(text: "Upload"),
                Tab(text: "URL"),
              ],
            ),
          ),

        // Tab content
        Container(
          height: _hasVideo ? 200 : 150,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: widget.allowUrlInput
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUploadTab(colorScheme, textStyles),
                    _buildUrlTab(colorScheme, textStyles),
                  ],
                )
              : _buildUploadTab(colorScheme, textStyles),
        ),

        // Helper text
        if (!_hasVideo)
          Text(
            "Supported formats: MP4, MOV, AVI (Max 50MB) or paste a YouTube/Vimeo URL",
            style: textStyles.paragraph.copyWith(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadTab(
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    if (_hasVideo) {
      return _buildVideoPreview(colorScheme, textStyles);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _isUploading ? null : _pickVideo,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: _isUploading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      "Uploading video...",
                      style: textStyles.paragraph.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "This may take a few minutes",
                      style: textStyles.paragraph.copyWith(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      "Click to browse files",
                      style: textStyles.paragraph.copyWith(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUrlTab(
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link, size: 32, color: colorScheme.primary),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: "Paste YouTube, Vimeo, or direct video URL",
              hintStyle: textStyles.paragraph.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: textStyles.paragraph,
            onChanged: _updateUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return Stack(
      children: [
        // Video preview
        Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                "Video Ready",
                style: textStyles.paragraph.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (widget.videoUrl != null && widget.videoUrl!.length > 40)
                Text(
                  "${widget.videoUrl!.substring(0, 40)}...",
                  style: textStyles.paragraph.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else if (widget.videoUrl != null)
                Text(
                  widget.videoUrl!,
                  style: textStyles.paragraph.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),

        // Remove button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _removeVideo,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),

        // Replace button
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: _isUploading ? null : _pickVideo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "Replace",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
