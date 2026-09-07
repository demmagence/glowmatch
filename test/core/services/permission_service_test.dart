import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowmatch/core/services/permission_service.dart';
import 'package:glowmatch/core/widgets/permission_rationale_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Permission enums & status properties', () {
    test('AppPermissionType contains all required types', () {
      expect(AppPermissionType.values, contains(AppPermissionType.camera));
      expect(AppPermissionType.values, contains(AppPermissionType.photos));
      expect(AppPermissionType.values, contains(AppPermissionType.location));
      expect(AppPermissionType.values, contains(AppPermissionType.notification));
    });

    test('AppPermissionStatus contains all required statuses', () {
      expect(AppPermissionStatus.values, contains(AppPermissionStatus.granted));
      expect(AppPermissionStatus.values, contains(AppPermissionStatus.denied));
      expect(
        AppPermissionStatus.values,
        contains(AppPermissionStatus.permanentlyDenied),
      );
      expect(
        AppPermissionStatus.values,
        contains(AppPermissionStatus.restricted),
      );
      expect(
        AppPermissionStatus.values,
        contains(AppPermissionStatus.serviceDisabled),
      );
      expect(
        AppPermissionStatus.values,
        contains(AppPermissionStatus.unavailable),
      );
    });

    test('AppPermissionStatus getters function correctly', () {
      const granted = AppPermissionStatus.granted;
      expect(granted.isGranted, isTrue);
      expect(granted.isPermanentlyDenied, isFalse);
      expect(granted.isDenied, isFalse);
      expect(granted.isServiceDisabled, isFalse);

      const denied = AppPermissionStatus.denied;
      expect(denied.isGranted, isFalse);
      expect(denied.isPermanentlyDenied, isFalse);
      expect(denied.isDenied, isTrue);

      const permDenied = AppPermissionStatus.permanentlyDenied;
      expect(permDenied.isPermanentlyDenied, isTrue);
      expect(permDenied.isGranted, isFalse);

      const disabled = AppPermissionStatus.serviceDisabled;
      expect(disabled.isServiceDisabled, isTrue);
      expect(disabled.isGranted, isFalse);
    });
  });

  group('PermissionService singleton and methods', () {
    test('PermissionService singleton is accessible', () {
      final s1 = PermissionService.instance;
      final s2 = PermissionService();
      expect(s1, equals(s2));
    });

    test('Permission methods return without throwing in test environment', () async {
      final service = PermissionService.instance;

      // These call underlying plugins which return safe fallbacks in test environment
      final camStatus = await service.checkCameraPermission();
      expect(camStatus, isA<AppPermissionStatus>());

      final photoStatus = await service.checkPhotoPermission();
      expect(photoStatus, isA<AppPermissionStatus>());

      final photosStatus = await service.checkPhotosPermission();
      expect(photosStatus, isA<AppPermissionStatus>());

      final locStatus = await service.checkLocationPermission();
      expect(locStatus, isA<AppPermissionStatus>());

      final notifStatus = await service.checkNotificationPermission();
      expect(notifStatus, isA<AppPermissionStatus>());
    });
  });

  group('PermissionRationaleDialog widget tests', () {
    testWidgets('renders camera permission rationale with retry button', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRationaleDialog(
              permissionType: AppPermissionType.camera,
              status: AppPermissionStatus.denied,
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera Access Needed'), findsOneWidget);
      expect(find.text('Grant'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      await tester.tap(find.text('Grant'));
      await tester.pumpAndSettle();
      expect(retryPressed, isTrue);
    });

    testWidgets('renders permanently denied dialog with Settings action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionRationaleDialog(
              permissionType: AppPermissionType.photos,
              status: AppPermissionStatus.permanentlyDenied,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Photo Access Needed'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.text(
          'Permission is permanently restricted. You can enable it from your device system settings.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders service disabled dialog for location', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PermissionRationaleDialog(
              permissionType: AppPermissionType.location,
              status: AppPermissionStatus.serviceDisabled,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Location Access Needed'), findsOneWidget);
      expect(find.text('Turn On'), findsOneWidget);
    });
  });
}
