import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabunganku/core/widgets/permission_dialog.dart';

class PermissionService {
  /// Check if a specific permission is granted
  static Future<bool> isGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Request a permission directly triggering the native system dialog
  static Future<bool> requestPermission(
    BuildContext context, {
    required Permission permission,
    required String title,
    required String description,
    required IconData icon,
  }) async {
    // 1. Check current status
    var status = await permission.status;

    // 2. If already granted, return true
    if (status.isGranted) return true;

    // 3. Request native permission directly
    status = await permission.request();

    // 4. If permanently denied, show settings dialog
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, title);
      }
      return false;
    }

    return status.isGranted;
  }

  /// Show a dialog directing the user to app settings
  static void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin $permissionName Dibutuhkan'),
        content: Text(
          'Anda telah menolak izin $permissionName secara permanen. '
          'Silakan aktifkan izin ini di Pengaturan Aplikasi agar fitur dapat digunakan.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}
