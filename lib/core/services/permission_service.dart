import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionType {
  camera,
  photos,
  location,
  notification,
}

enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  serviceDisabled,
  unavailable;

  bool get isGranted => this == AppPermissionStatus.granted;
  bool get isDenied => this == AppPermissionStatus.denied;
  bool get isPermanentlyDenied => this == AppPermissionStatus.permanentlyDenied;
  bool get isRestricted => this == AppPermissionStatus.restricted;
  bool get isServiceDisabled => this == AppPermissionStatus.serviceDisabled;
  bool get isUnavailable => this == AppPermissionStatus.unavailable;
}

class PermissionService {
  @visibleForTesting
  PermissionService.internal();

  factory PermissionService() => instance;

  static PermissionService instance = PermissionService.internal();

  // ── Camera ─────────────────────────────────────────────────────────────

  Future<AppPermissionStatus> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return _mapPermissionStatus(status);
    } catch (e) {
      debugPrint('checkCameraPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  Future<AppPermissionStatus> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return _mapPermissionStatus(status);
    } catch (e) {
      debugPrint('requestCameraPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  // ── Photos / Gallery ───────────────────────────────────────────────────

  Future<AppPermissionStatus> checkPhotoPermission() async {
    try {
      if (kIsWeb) return AppPermissionStatus.granted;

      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        return _mapPermissionStatus(status);
      }

      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isGranted || photosStatus.isLimited) {
          return AppPermissionStatus.granted;
        }
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) {
          return AppPermissionStatus.granted;
        }
        if (photosStatus.isPermanentlyDenied ||
            storageStatus.isPermanentlyDenied) {
          return AppPermissionStatus.permanentlyDenied;
        }
        if (photosStatus.isRestricted || storageStatus.isRestricted) {
          return AppPermissionStatus.restricted;
        }
        return AppPermissionStatus.denied;
      }

      return AppPermissionStatus.granted;
    } catch (e) {
      debugPrint('checkPhotoPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  Future<AppPermissionStatus> checkPhotosPermission() => checkPhotoPermission();

  Future<AppPermissionStatus> requestPhotoPermission() async {
    try {
      if (kIsWeb) return AppPermissionStatus.granted;

      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return _mapPermissionStatus(status);
      }

      if (Platform.isAndroid) {
        // Request photos permission (Android 13+)
        final photoStatus = await Permission.photos.request();
        if (photoStatus.isGranted || photoStatus.isLimited) {
          return AppPermissionStatus.granted;
        }

        // If not granted, try storage permission (Android 12 and below)
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          return AppPermissionStatus.granted;
        }

        if (photoStatus.isPermanentlyDenied ||
            storageStatus.isPermanentlyDenied) {
          return AppPermissionStatus.permanentlyDenied;
        }
        if (photoStatus.isRestricted || storageStatus.isRestricted) {
          return AppPermissionStatus.restricted;
        }
        return AppPermissionStatus.denied;
      }

      return AppPermissionStatus.granted;
    } catch (e) {
      debugPrint('requestPhotoPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  Future<AppPermissionStatus> requestPhotosPermission() =>
      requestPhotoPermission();

  // ── Location ───────────────────────────────────────────────────────────

  Future<AppPermissionStatus> checkLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return AppPermissionStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();
      return _mapLocationPermission(permission);
    } catch (e) {
      debugPrint('checkLocationPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  Future<AppPermissionStatus> requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return AppPermissionStatus.serviceDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return _mapLocationPermission(permission);
    } catch (e) {
      debugPrint('requestLocationPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────

  Future<AppPermissionStatus> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return _mapPermissionStatus(status);
    } catch (e) {
      debugPrint('checkNotificationPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  Future<AppPermissionStatus> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return _mapPermissionStatus(status);
    } catch (e) {
      debugPrint('requestNotificationPermission error: $e');
      return AppPermissionStatus.denied;
    }
  }

  // ── Settings Navigation ────────────────────────────────────────────────

  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      debugPrint('openAppSettings error: $e');
      return false;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('openLocationSettings error: $e');
      return false;
    }
  }

  // ── Helper Mappers ─────────────────────────────────────────────────────

  AppPermissionStatus _mapPermissionStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return AppPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) {
      return AppPermissionStatus.restricted;
    }
    return AppPermissionStatus.denied;
  }

  AppPermissionStatus _mapLocationPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return AppPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return AppPermissionStatus.permanentlyDenied;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return AppPermissionStatus.denied;
    }
  }
}
