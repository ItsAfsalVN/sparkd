import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/services/storage_service.dart';
import 'dart:io';

import 'package:sparkd/core/utils/snackbar_helper.dart';

class MultiImageUpload extends StatefulWidget {
  final String? label;
  final String hintText;
  final List<String> imageUrls;
  final List<File> imageFiles;
  final Function(List<String>)? onChanged;
  final Function(List<File>)? onFilesChanged;
  final int maxImages;
  final bool isRequired;
  final bool uploadImmediately;

  const MultiImageUpload({
    super.key,
    this.label,
    this.hintText = "Upload images",
    this.imageUrls = const [],
    this.imageFiles = const [],
    this.onChanged,
    this.onFilesChanged,
    this.maxImages = 5,
    this.isRequired = false,
    this.uploadImmediately = true,
  });

  @override
  State<MultiImageUpload> createState() => _MultiImageUploadState();
}

class _MultiImageUploadState extends State<MultiImageUpload> {
  late List<String> _imageUrls;
  late List<File> _imageFiles;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageUrls = List.from(widget.imageUrls);
    _imageFiles = List.from(widget.imageFiles);
  }

  Future<void> _addImage() async {
    final currentCount = widget.uploadImmediately
        ? _imageUrls.length
        : _imageFiles.length;
    if (currentCount >= widget.maxImages) {
      _showMaxImagesSnackBar();
      return;
    }

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
          // Upload to Firebase Storage
          final storageService = sl<StorageService>();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storagePath = 'gigs/portfolio/$fileName';

          final downloadUrl = await storageService.uploadImage(
            imageFile,
            storagePath,
          );

          setState(() {
            _imageUrls.add(downloadUrl);
          });

          widget.onChanged?.call(_imageUrls);

          if (mounted) {
            showSnackbar(
              context,
              "Image uploaded successfully!",
              SnackBarType.success,
            );
          }
        } else {
          // Just store the file locally
          setState(() {
            _imageFiles.add(imageFile);
          });

          widget.onFilesChanged?.call(_imageFiles);

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

  void _removeImage(int index) {
    setState(() {
      if (widget.uploadImmediately) {
        _imageUrls.removeAt(index);
        widget.onChanged?.call(_imageUrls);
      } else {
        _imageFiles.removeAt(index);
        widget.onFilesChanged?.call(_imageFiles);
      }
    });
  }

  void _showMaxImagesSnackBar() {
    if (mounted) {
      showSnackbar(
        context,
        "You can upload a maximum of ${widget.maxImages} images",
        SnackBarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final displayItems = widget.uploadImmediately ? _imageUrls : _imageFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        // Label and counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: displayItems.isNotEmpty
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${displayItems.length}/${widget.maxImages}',
                style: textStyles.paragraph.copyWith(
                  fontSize: 12,
                  color: displayItems.isNotEmpty
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Images grid
        if (displayItems.isNotEmpty || _isUploading)
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Existing images
                ...displayItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  return _buildImageTile(index, colorScheme);
                }),

                // Upload progress indicator
                if (_isUploading)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Uploading",
                          style: textStyles.paragraph.copyWith(
                            fontSize: 10,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Add button
                if (displayItems.length < widget.maxImages && !_isUploading)
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: colorScheme.primary, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            "Add",
                            style: textStyles.paragraph.copyWith(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Upload area for empty state
        if (displayItems.isEmpty && !_isUploading)
          GestureDetector(
            onTap: _addImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.collections_outlined,
                    size: 48,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

        // Helper text
        Text(
          "Add up to ${widget.maxImages} portfolio samples (JPG, PNG, GIF - Max 5MB each)",
          style: textStyles.paragraph.copyWith(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildImageTile(int index, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImageWidget(index),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(int index) {
    if (widget.uploadImmediately) {
      final imageUrl = _imageUrls[index];
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
            );
          },
        );
      } else {
        return Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
            );
          },
        );
      }
    } else {
      final imageFile = _imageFiles[index];
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
          );
        },
      );
    }
  }
}
