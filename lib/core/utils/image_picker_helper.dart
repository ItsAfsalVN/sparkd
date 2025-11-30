import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../presentation/widgets/permission_dialog.dart';

/// Helper class to pick images with permission handling
class ImagePickerHelper {
  final PermissionService _permissionService = PermissionService();
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera with permission check
  Future<XFile?> pickImageFromCamera(BuildContext context) async {
    // Check camera permission
    final cameraGranted = await _permissionService.isCameraGranted();

    if (!cameraGranted) {
      // Request camera permission
      final granted = await _permissionService.requestCameraPermission();

      if (!granted) {
        // Show dialog to open settings
        if (context.mounted) {
          await PermissionDialog.showCameraPermissionDialog(
            context,
            onSettingsPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          );
        }
        return null;
      }
    }

    // Pick image
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery with permission check
  Future<XFile?> pickImageFromGallery(BuildContext context) async {
    // Check storage permission
    final storageGranted = await _permissionService.isStorageGranted();

    if (!storageGranted) {
      // Request storage permission
      final granted = await _permissionService.requestStoragePermission();

      if (!granted) {
        // Show dialog to open settings
        if (context.mounted) {
          await PermissionDialog.showStoragePermissionDialog(
            context,
            onSettingsPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          );
        }
        return null;
      }
    }

    // Pick image
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery with permission check
  Future<List<XFile>> pickMultipleImages(BuildContext context) async {
    // Check storage permission
    final storageGranted = await _permissionService.isStorageGranted();

    if (!storageGranted) {
      // Request storage permission
      final granted = await _permissionService.requestStoragePermission();

      if (!granted) {
        // Show dialog to open settings
        if (context.mounted) {
          await PermissionDialog.showStoragePermissionDialog(
            context,
            onSettingsPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          );
        }
        return [];
      }
    }

    // Pick images
    try {
      return await _picker.pickMultiImage(imageQuality: 85);
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Pick video from camera with permission check
  Future<XFile?> pickVideoFromCamera(BuildContext context) async {
    // Check camera and microphone permissions
    final cameraGranted = await _permissionService.isCameraGranted();
    final micGranted = await _permissionService.isMicrophoneGranted();

    if (!cameraGranted || !micGranted) {
      // Request permissions
      final permissions = await _permissionService.requestMediaPermissions();

      if (!permissions[Permission.camera]!.isGranted) {
        // Show dialog to open settings
        if (context.mounted) {
          await PermissionDialog.showCameraPermissionDialog(
            context,
            onSettingsPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          );
        }
        return null;
      }

      if (!permissions[Permission.microphone]!.isGranted) {
        if (context.mounted) {
          await PermissionDialog.showMicrophonePermissionDialog(
            context,
            onSettingsPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          );
        }
        return null;
      }
    }

    // Pick video
    try {
      return await _picker.pickVideo(source: ImageSource.camera);
    } catch (e) {
      debugPrint('Error picking video from camera: $e');
      return null;
    }
  }

  /// Pick video from gallery with permission check
  Future<XFile?> pickVideoFromGallery(BuildContext context) async {
    // Check storage permission
    final storageGranted = await _permissionService.isStorageGranted();

    if (!storageGranted) {
      // Request storage permission
      final granted = await _permissionService.requestStoragePermission();

      if (!granted) {
        // Show dialog to open settings
        if (context.mounted) {
          await PermissionDialog.showStoragePermissionDialog(
            context,
            onSettingsPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          );
        }
        return null;
      }
    }

    // Pick video
    try {
      return await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      return null;
    }
  }

  /// Show bottom sheet to choose between camera and gallery
  Future<XFile?> showImageSourcePicker(BuildContext context) async {
    return showModalBottomSheet<XFile>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromCamera(context);
                  if (context.mounted && image != null) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromGallery(context);
                  if (context.mounted && image != null) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
