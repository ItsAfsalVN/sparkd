import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/services/storage_service.dart';
import 'dart:io';

import 'package:sparkd/core/utils/snackbar_helper.dart';

class ImageUpload extends StatefulWidget {
  final String? label;
  final String hintText;
  final String? imageUrl;
  final File? imageFile;
  final Function(String?)? onChanged;
  final Function(File?)? onFileChanged;
  final bool isRequired;
  final double? aspectRatio;
  final bool uploadImmediately;

  const ImageUpload({
    super.key,
    this.label,
    this.hintText = "Upload an image",
    this.imageUrl,
    this.imageFile,
    this.onChanged,
    this.onFileChanged,
    this.isRequired = false,
    this.aspectRatio,
    this.uploadImmediately = true,
  });

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Show source selection dialog
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Pick image from selected source
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);

        if (widget.uploadImmediately) {
          // Upload to Firebase Storage immediately
          final storageService = sl<StorageService>();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storagePath = 'gigs/images/$fileName';

          final downloadUrl = await storageService.uploadImage(
            imageFile,
            storagePath,
          );
          widget.onChanged?.call(downloadUrl);

          if (mounted) {
            showSnackbar(
              context,
              "Image uploaded successfully!",
              SnackBarType.success,
            );
          }
        } else {
          // Just store the file locally
          widget.onFileChanged?.call(imageFile);
          if (mounted) {
            showSnackbar(context, "Image selected!", SnackBarType.success);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, "Error picking image: $e", SnackBarType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage() {
    if (widget.uploadImmediately) {
      widget.onChanged?.call(null);
    } else {
      widget.onFileChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final hasImage =
        (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ||
        widget.imageFile != null;

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

        // Upload container
        Container(
          height: widget.aspectRatio != null ? null : 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: hasImage
              ? _buildImagePreview(colorScheme)
              : _buildUploadArea(colorScheme, textStyles),
        ),

        // Helper text
        if (!hasImage)
          Text(
            "Supported formats: JPG, PNG, GIF (Max 5MB)",
            style: textStyles.paragraph.copyWith(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview(ColorScheme colorScheme) {
    return Stack(
      children: [
        // Image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: _buildImageWidget(),
          ),
        ),

        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
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
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _isUploading ? null : _pickImage,
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

  Widget _buildUploadArea(
    ColorScheme colorScheme,
    AppTextThemeExtension textStyles,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _isUploading ? null : _pickImage,
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
                      "Uploading...",
                      style: textStyles.paragraph.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    // Show file if available
    if (widget.imageFile != null) {
      return Image.file(
        widget.imageFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    }

    // Otherwise show URL
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return const Icon(Icons.image, size: 50, color: Colors.grey);
    }

    if (widget.imageUrl!.startsWith('http')) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    } else {
      return Image.file(
        File(widget.imageUrl!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    }
  }
}
