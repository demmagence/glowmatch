import 'package:flutter/material.dart';
import '../journal_viewmodel.dart';

class EmptySlot extends StatelessWidget {
  final String userId;
  final JournalViewModel vm;
  final Function(BuildContext, String, JournalViewModel) onShowPhotoSourceSheet;

  const EmptySlot({
    super.key,
    required this.userId,
    required this.vm,
    required this.onShowPhotoSourceSheet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onShowPhotoSourceSheet(context, userId, vm),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade400, width: 1.2),
          borderRadius: BorderRadius.circular(4),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 32, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
