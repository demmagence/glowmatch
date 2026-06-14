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
        'jan',
        'feb',
        'mar',
        'apr',
        'may',
        'jun',
        'jul',
        'aug',
        'sep',
        'oct',
        'nov',
        'dec',
      ];
      final idx = months.indexOf(monthStr);
      if (idx != -1) {
        month = idx + 1;
      }
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
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black;

    final dateA = _parseLoggedDate(entryA.loggedDate);
    final dateB = _parseLoggedDate(entryB.loggedDate);
    final isAFirst = dateA.isBefore(dateB);
    final earlier = isAFirst ? entryA : entryB;
    final later = isAFirst ? entryB : entryA;

    final diff = later.skinScore - earlier.skinScore;
    final String diffSign = diff >= 0 ? '+' : '';
    final String diffText = '$diffSign$diff';

    Color diffColor = const Color(0xFFFFD54F);
    String diffMsg = 'No change. Consistency is key! ⚖️';
    if (diff > 0) {
      diffColor = const Color(0xFF64DD17);
      diffMsg = '+$diff improvement! Great progress! 📈';
    } else if (diff < 0) {
      diffColor = const Color(0xFFFF8A80);
      diffMsg = '$diff difference. Keep consistent! 📉';
    }

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
                        earlier,
                        isDark,
                        borderColor,
                        shadowColor,
                      ),
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
                        later,
                        isDark,
                        borderColor,
                        shadowColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                    'PROGRESS ANALYSIS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildScoreDetailColumn(
                        'Before Score',
                        earlier.skinScore,
                        earlier.loggedDate,
                        textColor,
                        subtextColor,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: diffColor,
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          diffText,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      _buildScoreDetailColumn(
                        'After Score',
                        later.skinScore,
                        later.loggedDate,
                        textColor,
                        subtextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    height: 1,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      diffMsg,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

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

  Widget _buildScoreDetailColumn(
    String label,
    int score,
    String date,
    Color textColor,
    Color subtextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: subtextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: textColor,
          ),
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
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
