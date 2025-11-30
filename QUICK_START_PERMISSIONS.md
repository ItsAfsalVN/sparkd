# Permission System - Quick Start Guide

## 🚀 What's Been Implemented

Your Sparkd app now has a complete permission management system that handles:

- 📷 Camera access
- 🖼️ Photo library/Gallery access
- 🎤 Microphone access
- 🔔 Notifications
- 📍 Location (optional)

## 📦 Files Created

```
lib/core/
├── services/
│   └── permission_service.dart          # Core permission logic
├── presentation/
│   ├── screens/
│   │   └── permissions_screen.dart      # UI for requesting permissions
│   └── widgets/
│       └── permission_dialog.dart       # Permission dialogs
├── utils/
│   ├── image_picker_helper.dart         # Image picker with permissions
│   └── permission_utils.dart            # Mixins and utilities
└── examples/
    └── permission_examples.dart         # 8 usage examples

PERMISSIONS_GUIDE.md                     # Detailed documentation
PERMISSION_IMPLEMENTATION_SUMMARY.md     # Implementation overview
```

## ✅ Already Configured

- ✅ Android permissions in `AndroidManifest.xml`
- ✅ iOS usage descriptions in `Info.plist`
- ✅ `permission_handler` package added to `pubspec.yaml`
- ✅ Service registered in service locator
- ✅ No compilation errors

## 🎯 How to Use (3 Easy Ways)

### Option 1: Show Permission Screen (Recommended for First Launch)

Add this after user completes sign-up or onboarding:

```dart
import 'package:sparkd/core/presentation/screens/permissions_screen.dart';

// After sign-up success
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PermissionsScreen(
      onComplete: () {
        // User completed or skipped permissions
        Navigator.pop(context);
      },
    ),
  ),
);
```

### Option 2: Use ImagePickerHelper (Easiest for Media)

Automatically handles permissions when picking images/videos:

```dart
import 'package:sparkd/core/utils/image_picker_helper.dart';

final helper = ImagePickerHelper();

// Show bottom sheet to choose camera or gallery
final image = await helper.showImageSourcePicker(context);

// Or directly pick from camera
final photo = await helper.pickImageFromCamera(context);

// Or pick from gallery
final galleryImage = await helper.pickImageFromGallery(context);
```

### Option 3: Use PermissionMixin (For Custom Widgets)

Add permission methods to any widget:

```dart
import 'package:sparkd/core/utils/permission_utils.dart';

class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget> with PermissionMixin {
  Future<void> _useCamera() async {
    if (await ensureCameraPermission(context)) {
      // Camera permission granted!
      // Your camera code here
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _useCamera,
      child: Text('Take Photo'),
    );
  }
}
```

## 📱 Where to Integrate

### 1. **After Sign-Up** (Recommended)

Show the permissions screen after user completes sign-up flow:

**File:** `lib/features/auth/presentation/screens/sign_up_screen.dart` or wherever sign-up completes

```dart
// When sign-up is successful
context.navigateToPermissionsScreen(
  onComplete: () {
    // Navigate to dashboard or main screen
    Navigator.pushReplacementNamed(context, '/dashboard');
  },
);
```

### 2. **In Gig Creation**

Replace direct image picker usage with the helper:

**File:** Wherever you create gigs

```dart
// Old way:
// final picker = ImagePicker();
// final image = await picker.pickImage(source: ImageSource.camera);

// New way (with automatic permissions):
final helper = ImagePickerHelper();
final image = await helper.pickImageFromCamera(context);
```

### 3. **For Notifications**

Request notification permission at an appropriate time:

```dart
import 'package:sparkd/core/services/permission_service.dart';

final permissionService = PermissionService();

// Ask when user wants notifications
final granted = await permissionService.requestNotificationPermission();
```

## 🔧 Testing Your Implementation

1. **Uninstall the app** from your device/emulator
2. **Install fresh**: `flutter run`
3. **Test permission flow**:
   - Tap "Take Photo" → Should ask for camera permission
   - Deny it → Should show dialog to open settings
   - Grant it → Should work seamlessly

## 📖 Need More Help?

- **Detailed Guide**: See `PERMISSIONS_GUIDE.md` for complete documentation
- **Code Examples**: Check `lib/core/examples/permission_examples.dart` for 8 examples
- **Implementation Details**: Read `PERMISSION_IMPLEMENTATION_SUMMARY.md`

## 🎨 Customization

### Change Permission Screen Colors

Edit `lib/core/presentation/screens/permissions_screen.dart`

### Add Custom Permission

1. Add to `permission_service.dart`
2. Add to `permissions_screen.dart` permissions list
3. Add usage description to iOS `Info.plist`
4. Add permission to Android `AndroidManifest.xml`

## 🐛 Common Issues

**Issue**: Permission dialog doesn't show

- **Fix**: Rebuild app after modifying AndroidManifest.xml or Info.plist

**Issue**: "Settings" button doesn't work

- **Fix**: Use `openAppSettings()` from `permission_handler` package

**Issue**: App crashes on permission request

- **Fix**: Make sure usage descriptions are in iOS Info.plist

## ✨ Next Steps

1. **Integrate into sign-up flow** - Show permissions screen after user signs up
2. **Update gig creation** - Use ImagePickerHelper instead of direct ImagePicker
3. **Test on real devices** - Test both Android and iOS
4. **Customize UI** - Match permissions screen to your app theme

## 📞 Quick Reference

```dart
// Request single permission
await permissionService.requestCameraPermission();

// Request multiple permissions
await permissionService.requestMediaPermissions();

// Check if granted
bool granted = await permissionService.isCameraGranted();

// Pick image with auto permissions
final image = await ImagePickerHelper().pickImageFromCamera(context);

// Show permissions screen
Navigator.push(context, MaterialPageRoute(
  builder: (_) => PermissionsScreen(onComplete: () {}),
));
```

---

**You're all set! 🎉** The permission system is ready to use. Start by showing the PermissionsScreen after sign-up.
