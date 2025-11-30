import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/permission_service.dart';

/// Screen to request all necessary permissions on first launch
class PermissionsScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionsScreen({super.key, required this.onComplete});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PermissionService _permissionService = PermissionService();
  bool _isRequesting = false;

  final List<PermissionItem> _permissions = [
    PermissionItem(
      permission: Permission.camera,
      title: 'Camera',
      description: 'Take photos and videos for your gigs',
      icon: Icons.camera_alt,
    ),
    PermissionItem(
      permission: Permission.photos,
      title: 'Photos',
      description: 'Select images and videos from gallery',
      icon: Icons.photo_library,
    ),
    PermissionItem(
      permission: Permission.microphone,
      title: 'Microphone',
      description: 'Record audio for videos',
      icon: Icons.mic,
    ),
    PermissionItem(
      permission: Permission.notification,
      title: 'Notifications',
      description: 'Receive updates about gigs and messages',
      icon: Icons.notifications,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    for (final permissionItem in _permissions) {
      final status = await permissionItem.permission.status;
      setState(() {
        permissionItem.status = status;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      await _permissionService.requestMediaPermissions();
      await _permissionService.requestNotificationPermission();

      await _checkPermissions();

      // Navigate to next screen if at least essential permissions are granted
      final cameraGranted = await _permissionService.isCameraGranted();
      final storageGranted = await _permissionService.isStorageGranted();

      if (cameraGranted && storageGranted) {
        widget.onComplete();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please grant camera and storage permissions to continue',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  Future<void> _requestSinglePermission(PermissionItem item) async {
    final status = await item.permission.request();
    setState(() {
      item.status = status;
    });

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showOpenSettingsDialog(item.title);
      }
    }
  }

  void _showOpenSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission'),
        content: Text(
          'You have permanently denied $permissionName permission. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grant Permissions',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We need these permissions to provide you with the best experience',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _permissions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _permissions[index];
                    return _PermissionCard(
                      item: item,
                      onTap: () => _requestSinglePermission(item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _requestAllPermissions,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRequesting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Grant All Permissions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionItem {
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;
  PermissionStatus status;

  PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
    this.status = PermissionStatus.denied,
  });
}

class _PermissionCard extends StatelessWidget {
  final PermissionItem item;
  final VoidCallback onTap;

  const _PermissionCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGranted = item.status.isGranted;
    final isPermanentlyDenied = item.status.isPermanentlyDenied;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isGranted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.icon,
            color: isGranted ? Colors.green : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          item.description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: isGranted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : isPermanentlyDenied
            ? const Icon(Icons.settings, color: Colors.orange)
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: isGranted ? null : onTap,
      ),
    );
  }
}
