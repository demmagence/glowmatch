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
      const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
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
    // Order them chronologically so A is earlier, B is later
    final dateA = _parseLoggedDate(entryA.loggedDate);
    final dateB = _parseLoggedDate(entryB.loggedDate);
    final isAFirst = dateA.isBefore(dateB);
    final earlier = isAFirst ? entryA : entryB;
    final later = isAFirst ? entryB : entryA;

    final diff = later.skinScore - earlier.skinScore;
    final String diffSign = diff >= 0 ? '+' : '';
    final String diffText = '$diffSign$diff';

    Color diffColor = const Color(0xFFFFD54F); // Amber (no change)
    String diffMsg = 'No change. Consistency is key! ⚖️';
    if (diff > 0) {
      diffColor = const Color(0xFF64DD17); // Green (improved)
      diffMsg = '+$diff improvement! Great progress! 📈';
    } else if (diff < 0) {
      diffColor = const Color(0xFFFF8A80); // Red (declined)
      diffMsg = '$diff difference. Keep consistent! 📉';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'COMPARE GLOW',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Side-by-side photos
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'BEFORE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      _buildCompareImageCard(earlier),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'AFTER',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      _buildCompareImageCard(later),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Comparison Metrics Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROGRESS ANALYSIS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildScoreDetailColumn('Before Score', earlier.skinScore, earlier.loggedDate),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: diffColor,
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
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
                      _buildScoreDetailColumn('After Score', later.skinScore, later.loggedDate),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black, height: 1),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      diffMsg,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black, width: 1.5),
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

  Widget _buildScoreDetailColumn(String label, int score, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        Text(
          date,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCompareImageCard(JournalEntry entry) {
    final bool isLocalFile = (entry.photoPath?.startsWith('/') ?? false) || (entry.photoPath?.startsWith('C:') ?? false);
    final bool isNetwork = entry.photoPath?.startsWith('http') ?? false;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
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
                errorBuilder: (c, e, s) => _placeholder(),
              )
            : isNetwork
                ? Image.network(
                    entry.photoPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _placeholder(),
                  )
                : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.face, color: Colors.grey, size: 40),
    );
  }
}
