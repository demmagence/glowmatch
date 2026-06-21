import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/models.dart';

class JournalCompareScreen extends StatelessWidget {
  final JournalEntry entryA;
  final JournalEntry entryB;

  const JournalCompareScreen({
    super.key,
    required this.entryA,
    required this.entryB,
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
      const months = [
        'jan', 'feb', 'mar', 'apr', 'may', 'jun',
        'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
      ];
      final idx = months.indexOf(monthStr);
      if (idx != -1) month = idx + 1;
      return DateTime(now.year, month, day);
    }
    return now;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor =
        isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black;

    final dateA = _parseLoggedDate(entryA.loggedDate);
    final dateB = _parseLoggedDate(entryB.loggedDate);
    final isAFirst = dateA.isBefore(dateB);
    final earlier = isAFirst ? entryA : entryB;
    final later = isAFirst ? entryB : entryA;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'COMPARE GLOW',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ── Side-by-side photos ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'BEFORE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCompareImageCard(
                          earlier, isDark, borderColor, shadowColor),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'AFTER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCompareImageCard(
                          later, isDark, borderColor, shadowColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Progress details (dates + notes only) ─────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROGRESS DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDateNoteColumn(
                          'Before',
                          earlier.loggedDate,
                          earlier.notes,
                          textColor,
                          subtextColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateNoteColumn(
                          'After',
                          later.loggedDate,
                          later.notes,
                          textColor,
                          subtextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Close button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: borderColor, width: 1.5),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CLOSE COMPARISON',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNoteColumn(
    String label,
    String date,
    String? notes,
    Color textColor,
    Color subtextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: subtextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            notes,
            style: TextStyle(
              fontSize: 13,
              color: subtextColor,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompareImageCard(
    JournalEntry entry,
    bool isDark,
    Color borderColor,
    Color shadowColor,
  ) {
    final bool isLocalFile =
        (entry.photoPath?.startsWith('/') ?? false) ||
        (entry.photoPath?.startsWith('C:') ?? false);
    final bool isNetwork = entry.photoPath?.startsWith('http') ?? false;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: isLocalFile
            ? Image.file(
                File(entry.photoPath!),
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _placeholder(isDark),
              )
            : isNetwork
            ? Image.network(
                entry.photoPath!,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _placeholder(isDark),
              )
            : _placeholder(isDark),
      ),
    );
  }

  Widget _placeholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Icon(
        Icons.face,
        color: isDark ? Colors.grey.shade600 : Colors.grey,
        size: 40,
      ),
    );
  }
}
