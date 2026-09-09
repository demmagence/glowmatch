import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class PermissionRationaleDialog extends StatelessWidget {
  final AppPermissionType permissionType;
  final AppPermissionStatus status;
  final String? customTitle;
  final String? customMessage;
  final VoidCallback? onRetry;

  const PermissionRationaleDialog({
    super.key,
    required this.permissionType,
    required this.status,
    this.customTitle,
    this.customMessage,
    this.onRetry,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AppPermissionType permissionType,
    required AppPermissionStatus status,
    String? customTitle,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => PermissionRationaleDialog(
        permissionType: permissionType,
        status: status,
        customTitle: customTitle,
        customMessage: customMessage,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;

    final info = _getPermissionInfo(context);

    final bool isPermanentlyDenied =
        status == AppPermissionStatus.permanentlyDenied;
    final bool isServiceDisabled =
        status == AppPermissionStatus.serviceDisabled;

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2.0),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: info.color, width: 2.0),
            ),
            child: Icon(info.icon, size: 40, color: info.color),
          ),
          const SizedBox(height: 16),
          Text(
            customTitle ?? info.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            customMessage ?? info.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          if (isPermanentlyDenied) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                border: Border.all(color: Colors.amber.shade900, width: 1.0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Permission is permanently restricted. You can enable it from your device system settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  side: BorderSide(color: borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.pinkAccent : Colors.pink,
                  foregroundColor: Colors.white,
                  side: BorderSide(color: borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.pop(context, true);
                  if (isPermanentlyDenied) {
                    await PermissionService.instance.openAppSettings();
                  } else if (isServiceDisabled) {
                    await PermissionService.instance.openLocationSettings();
                  } else if (onRetry != null) {
                    onRetry!();
                  }
                },
                child: Text(
                  isPermanentlyDenied
                      ? 'Settings'
                      : (isServiceDisabled ? 'Turn On' : 'Grant'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _PermissionInfo _getPermissionInfo(BuildContext context) {
    switch (permissionType) {
      case AppPermissionType.camera:
        return _PermissionInfo(
          title: 'Camera Access Needed',
          description:
              'GlowMatch uses your camera to scan cosmetic ingredient lists and track your daily skin progress photos.',
          icon: Icons.camera_alt_outlined,
          color: Colors.pink,
        );
      case AppPermissionType.photos:
        return _PermissionInfo(
          title: 'Photo Access Needed',
          description:
              'GlowMatch requires access to your photo library to select skincare product pictures and upload progress logs.',
          icon: Icons.photo_library_outlined,
          color: Colors.purple,
        );
      case AppPermissionType.location:
        return _PermissionInfo(
          title: 'Location Access Needed',
          description:
              'GlowMatch uses your local weather and temperature to suggest dynamic, climate-adaptive skincare routines.',
          icon: Icons.location_on_outlined,
          color: Colors.amber.shade800,
        );
      case AppPermissionType.notification:
        return _PermissionInfo(
          title: 'Notification Access Needed',
          description:
              'GlowMatch sends scheduled morning and evening routine alerts so you never miss your skincare regimen.',
          icon: Icons.notifications_active_outlined,
          color: Colors.blue,
        );
    }
  }
}

class _PermissionInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _PermissionInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
