import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabunganku/core/widgets/permission_dialog.dart';

class PermissionService {

  static Future<bool> isGranted(Permission permission) async {
    return await permission.isGranted;
  }

static Future<bool> requestPermission(
    BuildContext context, {
    required Permission permission,
    required String title,
    required String description,
    required IconData icon,
  }) async {

    var status = await permission.status;

if (status.isGranted) return true;

status = await permission.request();

if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, title);
      }
      return false;
    }

    return status.isGranted;
  }

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
