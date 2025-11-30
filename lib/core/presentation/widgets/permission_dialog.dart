import 'package:flutter/material.dart';

/// Dialog to explain why permission is needed
class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String permissionName;
  final VoidCallback onSettingsPressed;
  final VoidCallback? onCancelPressed;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.permissionName,
    required this.onSettingsPressed,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (onCancelPressed != null)
          TextButton(onPressed: onCancelPressed, child: const Text('Cancel')),
        TextButton(
          onPressed: onSettingsPressed,
          child: const Text('Open Settings'),
        ),
      ],
    );
  }

  /// Show camera permission dialog
  static Future<void> showCameraPermissionDialog(
    BuildContext context, {
    required VoidCallback onSettingsPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Camera Permission Required',
        message:
            'This app needs camera access to take photos and videos for gig creation. Please enable it in settings.',
        permissionName: 'Camera',
        onSettingsPressed: onSettingsPressed,
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show storage permission dialog
  static Future<void> showStoragePermissionDialog(
    BuildContext context, {
    required VoidCallback onSettingsPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Storage Permission Required',
        message:
            'This app needs storage access to select images and videos from your gallery. Please enable it in settings.',
        permissionName: 'Storage',
        onSettingsPressed: onSettingsPressed,
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show notification permission dialog
  static Future<void> showNotificationPermissionDialog(
    BuildContext context, {
    required VoidCallback onSettingsPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Notification Permission Required',
        message:
            'Enable notifications to receive updates about gigs, messages, and important alerts.',
        permissionName: 'Notifications',
        onSettingsPressed: onSettingsPressed,
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show location permission dialog
  static Future<void> showLocationPermissionDialog(
    BuildContext context, {
    required VoidCallback onSettingsPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Location Permission Required',
        message:
            'This app needs location access to show you local gigs near you.',
        permissionName: 'Location',
        onSettingsPressed: onSettingsPressed,
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show microphone permission dialog
  static Future<void> showMicrophonePermissionDialog(
    BuildContext context, {
    required VoidCallback onSettingsPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Microphone Permission Required',
        message:
            'This app needs microphone access to record videos with audio.',
        permissionName: 'Microphone',
        onSettingsPressed: onSettingsPressed,
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show generic permission rationale dialog
  static Future<bool?> showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Continue',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
