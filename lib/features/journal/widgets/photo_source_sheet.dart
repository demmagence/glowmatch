import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glowmatch/l10n/app_localizations.dart';
import '../journal_viewmodel.dart';
import 'source_option.dart';

void showPhotoSourceSheet(
  BuildContext context,
  String userId,
  JournalViewModel vm,
  Future<void> Function(BuildContext, String, JournalViewModel, ImageSource)
  doUpload,
) {
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addProgressPhoto,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.chooseCaptureGlow,
                style: TextStyle(fontSize: 13, color: subtextColor),
              ),
              const SizedBox(height: 24),

              SourceOption(
                icon: Icons.camera_alt_outlined,
                label: l10n.takePhoto,
                subtitle: l10n.useCameraNow,
                onTap: () async {
                  Navigator.pop(context);
                  await doUpload(context, userId, vm, ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),

              SourceOption(
                icon: Icons.photo_library_outlined,
                label: l10n.chooseFromGallery,
                subtitle: l10n.pickExistingPhoto,
                onTap: () async {
                  Navigator.pop(context);
                  await doUpload(context, userId, vm, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
