# Permission System Implementation

This document explains how to use the permission system implemented in the Sparkd app.

## Overview

The app now includes a comprehensive permission handling system that manages:

- Camera access
- Photo library/storage access
- Microphone access
- Notifications
- Location (optional, for local gigs feature)

## Components

### 1. PermissionService (`lib/core/services/permission_service.dart`)

Core service that handles all permission requests and checks.

**Key Methods:**

```dart
// Request individual permissions
await permissionService.requestCameraPermission();
await permissionService.requestStoragePermission();
await permissionService.requestNotificationPermission();
await permissionService.requestMicrophonePermission();

// Request multiple permissions at once
await permissionService.requestEssentialPermissions(); // Camera, Photos, Notifications
await permissionService.requestMediaPermissions(); // Camera, Photos, Microphone

// Check if permission is granted
bool granted = await permissionService.isCameraGranted();
```

### 2. PermissionsScreen (`lib/core/presentation/screens/permissions_screen.dart`)

A dedicated screen that displays all permissions and allows users to grant them.

**Usage:**

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PermissionsScreen(
      onComplete: () {
        // Called when user completes or skips
        Navigator.pushReplacement(context, ...);
      },
    ),
  ),
);
```

### 3. ImagePickerHelper (`lib/core/utils/image_picker_helper.dart`)

Utility class that combines image picking with automatic permission handling.

**Usage:**

```dart
final helper = ImagePickerHelper();

// Pick from camera (auto-handles camera permission)
XFile? image = await helper.pickImageFromCamera(context);

// Pick from gallery (auto-handles storage permission)
XFile? image = await helper.pickImageFromGallery(context);

// Pick video with audio (auto-handles camera + microphone)
XFile? video = await helper.pickVideoFromCamera(context);

// Show bottom sheet to choose source
XFile? image = await helper.showImageSourcePicker(context);
```

### 4. PermissionMixin (`lib/core/utils/permission_utils.dart`)

Mixin that adds permission methods to any widget.

**Usage:**

```dart
class MyWidget extends StatefulWidget with PermissionMixin {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Ensure permission before using camera
        if (await ensureCameraPermission(context)) {
          // Camera permission granted, proceed
          takePicture();
        }
      },
      child: Text('Take Photo'),
    );
  }
}
```

## Integration Guide

### Step 1: Show Permissions Screen on First Launch

Add to your app's initialization flow (e.g., after onboarding):

```dart
// In your auth flow or after onboarding
if (isFirstLaunch) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PermissionsScreen(
        onComplete: () {
          // Navigate to main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        },
      ),
    ),
  );
}
```

### Step 2: Use ImagePickerHelper for Media Selection

Replace direct ImagePicker usage with ImagePickerHelper:

**Before:**

```dart
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.camera);
```

**After:**

```dart
final helper = ImagePickerHelper();
final image = await helper.pickImageFromCamera(context);
// Permissions are automatically handled!
```

### Step 3: Request Permissions Before Critical Features

For features that require permissions:

```dart
// Example: Before creating a gig with media
Future<void> createGigWithMedia() async {
  final permissionService = sl<PermissionService>();

  // Request media permissions
  final permissions = await permissionService.requestMediaPermissions();

  if (permissions[Permission.camera]!.isGranted &&
      permissions[Permission.photos]!.isGranted) {
    // Proceed with media selection
    proceedWithGigCreation();
  } else {
    // Show message
    showSnackBar('Camera and storage permissions are required');
  }
}
```

## Platform-Specific Configuration

### Android (AndroidManifest.xml)

Already configured with:

- Camera permission
- Storage permissions (with SDK version handling for Android 13+)
- Microphone permission
- Notification permission (Android 13+)
- Location permissions (optional)

### iOS (Info.plist)

Already configured with usage descriptions for:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSUserNotificationsUsageDescription`

## Best Practices

1. **Request permissions in context**: Always request permissions when the user is about to use a feature that needs it.

2. **Explain why**: The permission dialogs already include descriptions, but you can show additional UI to explain benefits.

3. **Handle denials gracefully**: Use the helper classes which automatically show dialogs to guide users to settings if needed.

4. **Don't request all at once**: Only request essential permissions upfront (camera, photos, notifications). Request others (like location) when needed.

5. **Check before assuming**: Always check if permission is granted before using a feature, even if you requested it before (user might have revoked it).

## Example: Complete Gig Creation Flow

```dart
class CreateGigScreen extends StatefulWidget {
  @override
  _CreateGigScreenState createState() => _CreateGigScreenState();
}

class _CreateGigScreenState extends State<CreateGigScreen> with PermissionMixin {
  final ImagePickerHelper _imagePicker = ImagePickerHelper();
  List<XFile> _selectedImages = [];

  Future<void> _addMedia() async {
    // Show source selection
    final image = await _imagePicker.showImageSourcePicker(context);

    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Gig')),
      body: Column(
        children: [
          // Media grid
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: _addMedia, // Permission handled automatically!
                  child: Icon(Icons.add_photo_alternate, size: 48),
                );
              }
              return Image.file(File(_selectedImages[index - 1].path));
            },
          ),
        ],
      ),
    );
  }
}
```

## Troubleshooting

**Issue**: Permission dialog not showing

- **Solution**: Make sure you've run `flutter pub get` to install `permission_handler`
- **Solution**: Rebuild the app after modifying AndroidManifest.xml or Info.plist

**Issue**: "Settings" button doesn't work

- **Solution**: The `openAppSettings()` function is provided by `permission_handler` package

**Issue**: Permission permanently denied

- **Solution**: The helper classes will automatically show a dialog directing users to Settings

## Testing

Test the permission flow:

1. Fresh install the app
2. Try to access camera → should show permission request
3. Deny permission → should show dialog with "Open Settings" option
4. Grant permission in settings → return to app and try again
5. Uninstall and test "Don't ask again" scenario

## Service Locator Integration

The PermissionService is registered in the service locator:

```dart
// Already registered in service_locator.dart
sl.registerLazySingleton(() => PermissionService());

// Use anywhere in app
final permissionService = sl<PermissionService>();
```
