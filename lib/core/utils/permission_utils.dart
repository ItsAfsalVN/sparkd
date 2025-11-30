import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../presentation/screens/permissions_screen.dart';

/// Extension on BuildContext to easily navigate to permissions screen
extension PermissionExtension on BuildContext {
  /// Navigate to permissions screen
  Future<void> navigateToPermissionsScreen({
    required VoidCallback onComplete,
  }) async {
    await Navigator.of(this).push(
      MaterialPageRoute(
        builder: (context) => PermissionsScreen(onComplete: onComplete),
      ),
    );
  }
}

/// Mixin to add permission checking functionality to any widget
mixin PermissionMixin {
  final PermissionService permissionService = PermissionService();

  /// Check and request camera permission
  Future<bool> ensureCameraPermission(BuildContext context) async {
    final granted = await permissionService.requestCameraPermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required')),
      );
    }
    return granted;
  }

  /// Check and request storage permission
  Future<bool> ensureStoragePermission(BuildContext context) async {
    final granted = await permissionService.requestStoragePermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required')),
      );
    }
    return granted;
  }

  /// Check and request notification permission
  Future<bool> ensureNotificationPermission(BuildContext context) async {
    final granted = await permissionService.requestNotificationPermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission is recommended')),
      );
    }
    return granted;
  }

  /// Check and request media permissions (camera + storage + mic)
  Future<bool> ensureMediaPermissions(BuildContext context) async {
    final statuses = await permissionService.requestMediaPermissions();
    final allGranted = statuses.values.every(
      (status) => status == PermissionStatus.granted,
    );

    if (!allGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media permissions are required')),
      );
    }
    return allGranted;
  }
}
