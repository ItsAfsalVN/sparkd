import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Service to handle all app permissions
class PermissionService {
  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    debugPrint('Camera permission status: $status');
    return status.isGranted;
  }

  /// Request storage/photo library permission
  Future<bool> requestStoragePermission() async {
    PermissionStatus status;

    // For Android 13+ use photos permission, otherwise use storage
    if (await Permission.photos.isRestricted ||
        await Permission.photos.isPermanentlyDenied) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.photos.request();
    }

    debugPrint('Storage/Photos permission status: $status');
    return status.isGranted;
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    debugPrint('Notification permission status: $status');
    return status.isGranted;
  }

  /// Request location permission (if needed for local gigs)
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    debugPrint('Location permission status: $status');
    return status.isGranted;
  }

  /// Request microphone permission (for video recording)
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    debugPrint('Microphone permission status: $status');
    return status.isGranted;
  }

  /// Request all essential permissions for the app
  Future<Map<Permission, PermissionStatus>>
  requestEssentialPermissions() async {
    debugPrint('Requesting essential permissions...');

    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.notification,
    ].request();

    debugPrint('Essential permissions status: $statuses');
    return statuses;
  }

  /// Request media permissions (camera, photos, microphone)
  Future<Map<Permission, PermissionStatus>> requestMediaPermissions() async {
    debugPrint('Requesting media permissions...');

    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.microphone,
    ].request();

    debugPrint('Media permissions status: $statuses');
    return statuses;
  }

  /// Check if camera permission is granted
  Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if storage/photos permission is granted
  Future<bool> isStorageGranted() async {
    final photosGranted = await Permission.photos.isGranted;
    final storageGranted = await Permission.storage.isGranted;
    return photosGranted || storageGranted;
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }

  /// Open app settings if permission is permanently denied
  Future<bool> openSettings() async {
    debugPrint('Opening app settings...');
    return await openAppSettings();
  }

  /// Show rationale and request permission
  Future<bool> requestPermissionWithRationale(
    Permission permission, {
    required String rationaleTitle,
    required String rationaleMessage,
  }) async {
    final status = await permission.status;

    if (status.isDenied) {
      // First time asking or user previously denied
      final result = await permission.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // User permanently denied, need to open settings
      debugPrint('Permission $permission is permanently denied');
      return false;
    } else if (status.isGranted) {
      return true;
    }

    return false;
  }

  /// Check permission status
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Request permission if not granted
  Future<bool> ensurePermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }

    final status = await permission.request();
    return status.isGranted;
  }
}
