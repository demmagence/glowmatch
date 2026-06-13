import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../journal_viewmodel.dart';
import 'photo_card.dart';
import 'empty_slot.dart';

class PhotoGridWidget extends StatelessWidget {
  final List<JournalEntry> entries;
  final String userId;
  final JournalViewModel vm;
  final Set<String> selectedEntryIds;
  final bool isCompareMode;
  final Function(String id) onToggleSelection;
  final Function(BuildContext ctx, String uid, JournalViewModel v) onShowPhotoSourceSheet;

  const PhotoGridWidget({
    super.key,
    required this.entries,
    required this.userId,
    required this.vm,
    required this.selectedEntryIds,
    required this.isCompareMode,
    required this.onToggleSelection,
    required this.onShowPhotoSourceSheet,
  });

  DateTime _parseLoggedDate(String dateStr) {
    final now = DateTime.now();
    if (dateStr.toLowerCase() == 'today') {
      return DateTime(now.year, now.month, now.day);
    }
    final parts = dateStr.trim().split(' ');
    if (parts.length >= 2) {
      final monthStr = parts[0].toLowerCase();
      final dayStr = parts[1];
      final day = int.tryParse(dayStr) ?? 1;
      int month = now.month;
      const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
      final idx = months.indexOf(monthStr);
      if (idx != -1) {
        month = idx + 1;
      }
      return DateTime(now.year, month, day);
    }
    return now;
  }

  String _getWeekLabel(DateTime entryDate, DateTime now) {
    final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(entryDay).inDays;

    if (diffDays < 0) {
      return 'This Week';
    }
    if (diffDays < 7) {
      return 'This Week';
    } else if (diffDays < 14) {
      return 'Last Week';
    } else {
      final weeks = diffDays ~/ 7;
      return '$weeks Weeks Ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group by week label based on real DateTime values
    final sections = <String, List<JournalEntry>>{};
    for (final entry in entries) {
      final entryDate = _parseLoggedDate(entry.loggedDate);
      final label = _getWeekLabel(entryDate, now).toUpperCase();
      sections.putIfAbsent(label, () => []);
      sections[label]!.add(entry);
    }

    sections.forEach((sectionLabel, sectionEntries) {
      rows.add(
        Text(
          sectionLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      );
      rows.add(const SizedBox(height: 16));

      // Pair up entries in rows of 2
      for (int i = 0; i < sectionEntries.length; i += 2) {
        final a = sectionEntries[i];
        final b = i + 1 < sectionEntries.length ? sectionEntries[i + 1] : null;

        rows.add(Row(
          children: [
            Expanded(
              child: PhotoCard(
                entry: a,
                isSelected: selectedEntryIds.contains(a.id),
                isCompareMode: isCompareMode,
                onToggleSelection: () => onToggleSelection(a.id),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: b != null
                  ? PhotoCard(
                      entry: b,
                      isSelected: selectedEntryIds.contains(b.id),
                      isCompareMode: isCompareMode,
                      onToggleSelection: () => onToggleSelection(b.id),
                    )
                  : EmptySlot(
                      userId: userId,
                      vm: vm,
                      onShowPhotoSourceSheet: onShowPhotoSourceSheet,
                    ),
            ),
          ],
        ));
        rows.add(const SizedBox(height: 16));
      }

      rows.add(const SizedBox(height: 16));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
