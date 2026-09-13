import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glowmatch/l10n/app_localizations.dart';
import '../journal_viewmodel.dart';

void showAddProgressNoteDialog({
  required BuildContext context,
  required String userId,
  required JournalViewModel vm,
  required String pickedPath,
}) {
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  final borderColor = isDark ? Colors.white : Colors.black;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      final notesController = TextEditingController();
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: 2),
        ),
        title: Text(
          l10n.addProgressNote,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.5),
                  child: Image.file(File(pickedPath), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.skinFeelHint,
                  hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final notesText = notesController.text.trim();
              final success = await vm.addJournalEntryWithPhoto(
                userId: userId,
                localFilePath: pickedPath,
                notes: notesText,
              );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.skinLogUploaded,
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.black,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.uploadFailed,
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.black,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.logProgress,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
