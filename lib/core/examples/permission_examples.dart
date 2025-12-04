import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import '../services/permission_service.dart';
import '../presentation/screens/permissions_screen.dart';

/// Example integration showing how to use the permission system in your app

// ========================================
// Example 1: Show permissions screen on first launch
// ========================================
void showPermissionsOnFirstLaunch(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PermissionsScreen(
        onComplete: () {
          // User completed or skipped permissions
          Navigator.pop(context);
          // Continue to main app
        },
      ),
    ),
  );
}

// ========================================
// Example 2: Using ImagePickerHelper for media selection
// ========================================
/*
import '../utils/image_picker_helper.dart';

class CreateGigExample extends StatelessWidget {
  final ImagePickerHelper _imagePicker = ImagePickerHelper();

  Future<void> _selectImage(BuildContext context) async {
    // Show source picker (camera or gallery)
    final image = await _imagePicker.showImageSourcePicker(context);
    
    if (image != null) {
      // Use the selected image
      print('Selected image: ${image.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Gig')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _selectImage(context),
          child: Text('Add Photo'),
        ),
      ),
    );
  }
}
*/

// ========================================
// Example 3: Request permission before feature
// ========================================
Future<void> requestPermissionBeforeFeature(BuildContext context) async {
  final permissionService = PermissionService();

  // Request camera permission
  final granted = await permissionService.requestCameraPermission();

  if (granted) {
    // Permission granted, proceed with camera feature
    print('Camera permission granted!');
  } else {
    // Permission denied, show message
    if (context.mounted) {
      showSnackbar(
        context,
        'Camera permission is required for this feature',
        SnackBarType.error,
      );
    }
  }
}

// ========================================
// Example 4: Request multiple permissions
// ========================================
Future<void> requestMediaPermissions(BuildContext context) async {
  final permissionService = PermissionService();

  // Request camera, photos, and microphone permissions
  final statuses = await permissionService.requestMediaPermissions();

  // Check if all permissions granted
  final allGranted = statuses.values.every((status) => status.isGranted);

  if (allGranted) {
    print('All media permissions granted!');
  } else {
    print('Some permissions were denied');
  }
}

// ========================================
// Example 5: Check permission before action
// ========================================
Future<void> checkPermissionBeforeAction() async {
  final permissionService = PermissionService();

  // Check if camera permission is already granted
  final isGranted = await permissionService.isCameraGranted();

  if (isGranted) {
    // Already have permission, proceed
    print('Camera permission already granted');
  } else {
    // Need to request permission
    print('Need to request camera permission');
  }
}

// ========================================
// Example 6: Using PermissionMixin in a StatefulWidget
// ========================================
/*
import '../utils/permission_utils.dart';

class MyFeatureScreen extends StatefulWidget {
  @override
  _MyFeatureScreenState createState() => _MyFeatureScreenState();
}

class _MyFeatureScreenState extends State<MyFeatureScreen> 
    with PermissionMixin {
  
  Future<void> _useCamera() async {
    // Automatically request and check camera permission
    if (await ensureCameraPermission(context)) {
      // Permission granted, use camera
      print('Using camera...');
    } else {
      // Permission denied, handled by mixin
      print('Camera permission denied');
    }
  }

  Future<void> _selectMedia() async {
    // Request all media permissions
    if (await ensureMediaPermissions(context)) {
      // All permissions granted
      print('Can use camera, microphone, and gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Feature')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _useCamera,
            child: Text('Use Camera'),
          ),
          ElevatedButton(
            onPressed: _selectMedia,
            child: Text('Select Media'),
          ),
        ],
      ),
    );
  }
}
*/

// ========================================
// Example 7: Request notification permission
// ========================================
Future<void> enableNotifications(BuildContext context) async {
  final permissionService = PermissionService();

  // Request notification permission
  final granted = await permissionService.requestNotificationPermission();

  if (granted) {
    print('Notifications enabled!');
  } else {
    if (context.mounted) {
      showSnackbar(
        context,
        'Enable notifications in settings to receive updates',
        SnackBarType.error,
      );
    }
  }
}

// ========================================
// Example 8: Open app settings if permission denied
// ========================================
/*
import 'package:permission_handler/permission_handler.dart';
import '../presentation/widgets/permission_dialog.dart';

Future<void> requestCameraWithSettings(BuildContext context) async {
  final permissionService = PermissionService();
  
  final granted = await permissionService.requestCameraPermission();
  
  if (!granted) {
    // Permission denied, show dialog to open settings
    if (context.mounted) {
      await PermissionDialog.showCameraPermissionDialog(
        context,
        onSettingsPressed: () {
          Navigator.of(context).pop();
          openAppSettings();
        },
      );
    }
  }
}
*/
