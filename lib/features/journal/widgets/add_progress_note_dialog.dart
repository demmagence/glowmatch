import 'dart:io';
import 'package:flutter/material.dart';
import '../journal_viewmodel.dart';

void showAddProgressNoteDialog({
  required BuildContext context,
  required String userId,
  required JournalViewModel vm,
  required String pickedPath,
}) {
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
          'Add Progress Note',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image preview
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.5),
                  child: Image.file(
                    File(pickedPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'How does your skin feel today? (optional)',
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
            child: Text('Cancel', style: TextStyle(color: textColor)),
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
              Navigator.pop(dialogContext); // dismiss dialog

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
                        '📸 Skin log uploaded! Score updated.',
                        style: TextStyle(color: isDark ? Colors.black : Colors.white),
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.black,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Upload failed. Try again.',
                        style: TextStyle(color: isDark ? Colors.black : Colors.white),
                      ),
                      backgroundColor: isDark ? Colors.white : Colors.black,
                    ),
                  );
                }
              }
            },
            child: const Text('Log Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
