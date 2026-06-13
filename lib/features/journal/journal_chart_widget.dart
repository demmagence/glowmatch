import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/models.dart';

class JournalChartWidget extends StatelessWidget {
  final List<JournalEntry> entries;

  const JournalChartWidget({super.key, required this.entries});

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
    // 1. Filter last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final filtered = entries.where((entry) {
      final date = _parseLoggedDate(entry.loggedDate);
      return date.isAfter(thirtyDaysAgo);
    }).toList();

    // 2. Sort chronologically
    filtered.sort((a, b) => _parseLoggedDate(a.loggedDate).compareTo(_parseLoggedDate(b.loggedDate)));

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
          children: [
            const Icon(Icons.show_chart, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No progress data for the last 30 days.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload progress photos to see your trend! 📈',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Convert entries to FlSpots
    final List<FlSpot> spots = [];
    for (int i = 0; i < filtered.length; i++) {
      spots.add(FlSpot(i.toDouble(), filtered[i].skinScore.toDouble()));
    }

    // Determine Y-axis limits
    double minY = 0;
    double maxY = 100;

    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 16, right: 24),
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
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: -0.2,
          maxX: spots.length - 0.8,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final entry = filtered[spot.spotIndex];
                  return LineTooltipItem(
                    '${entry.loggedDate}\nScore: ${entry.skinScore}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xFFEEEEEE),
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.black, width: 1.5),
              left: BorderSide(color: Colors.black, width: 1.5),
              top: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < filtered.length) {
                    // Only show first, last, and middle dates to avoid clutter
                    final showLabel = filtered.length <= 4 ||
                        idx == 0 ||
                        idx == filtered.length - 1 ||
                        (filtered.length > 2 && idx == (filtered.length / 2).floor());

                    if (showLabel) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          filtered[idx].loggedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.pinkAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeColor: Colors.black,
                    strokeWidth: 2,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
