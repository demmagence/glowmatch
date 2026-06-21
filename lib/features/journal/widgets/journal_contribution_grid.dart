import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

class JournalContributionGrid extends StatelessWidget {
  final List<JournalEntry> entries;

  const JournalContributionGrid({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? Colors.grey.shade900 : Colors.white;
    final shadowColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black;

    // Calculate dates
    final today = DateTime.now();
    final sundayOfCurrentWeek = today.subtract(Duration(days: today.weekday % 7));
    // Start date is 52 weeks before this week's Sunday
    final startDate = sundayOfCurrentWeek.subtract(const Duration(days: 52 * 7));

    // Map entries to days for quick lookup
    final Map<String, int> entryCounts = {};
    for (final entry in entries) {
      if (entry.createdAt != null) {
        final dateKey = _toDateKey(entry.createdAt!);
        entryCounts[dateKey] = (entryCounts[dateKey] ?? 0) + 1;
      }
    }

    // Build the columns of weeks
    final List<Widget> weekColumns = [];
    final List<String?> monthLabels = [];

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    for (int col = 0; col < 53; col++) {
      final weekStartDate = startDate.add(Duration(days: col * 7));
      
      // Determine month label
      if (col == 0 || weekStartDate.day <= 7) {
        monthLabels.add(months[weekStartDate.month - 1]);
      } else {
        monthLabels.add(null);
      }

      final List<Widget> dayCells = [];
      for (int row = 0; row < 7; row++) {
        final cellDate = weekStartDate.add(Duration(days: row));
        final dateKey = _toDateKey(cellDate);
        final count = entryCounts[dateKey] ?? 0;
        final cellColor = _getCellColor(count, isDark);

        // Tooltip message
        final countText = count == 0 ? 'no entries' : (count == 1 ? '1 entry' : '$count entries');
        final formattedDate = '${months[cellDate.month - 1]} ${cellDate.day}, ${cellDate.year}';
        final tooltipMessage = '$countText on $formattedDate';

        dayCells.add(
          Tooltip(
            message: tooltipMessage,
            triggerMode: TooltipTriggerMode.tap,
            preferBelow: false,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }

      weekColumns.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: dayCells.expand((cell) => [cell, const SizedBox(height: 2)]).toList()..removeLast(),
        ),
      );
    }

    // Month Row
    final List<Widget> monthRowItems = [];
    for (int col = 0; col < 53; col++) {
      final label = monthLabels[col];
      monthRowItems.add(
        SizedBox(
          width: 10,
          height: 12,
          child: label != null
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Glow Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekday Labels on Left
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 14), // Offset for month row
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10), // Sun
                        const SizedBox(height: 2),
                        const SizedBox(
                          height: 10,
                          child: Text('Mon', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        ),
                        const SizedBox(height: 2),
                        const SizedBox(height: 10), // Tue
                        const SizedBox(height: 2),
                        const SizedBox(
                          height: 10,
                          child: Text('Wed', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        ),
                        const SizedBox(height: 2),
                        const SizedBox(height: 10), // Thu
                        const SizedBox(height: 2),
                        const SizedBox(
                          height: 10,
                          child: Text('Fri', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        ),
                        const SizedBox(height: 2),
                        const SizedBox(height: 10), // Sat
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                // Grid + Month labels
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month labels row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: monthRowItems.expand((m) => [m, const SizedBox(width: 2)]).toList()..removeLast(),
                    ),
                    const SizedBox(height: 4),
                    // Grid cells row of week columns
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: weekColumns.expand((col) => [col, const SizedBox(width: 2)]).toList()..removeLast(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Legend at bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Less', style: TextStyle(fontSize: 8, color: Colors.grey)),
              const SizedBox(width: 4),
              _buildLegendCell(_getCellColor(0, isDark)),
              const SizedBox(width: 2),
              _buildLegendCell(_getCellColor(1, isDark)),
              const SizedBox(width: 2),
              _buildLegendCell(_getCellColor(2, isDark)),
              const SizedBox(width: 2),
              _buildLegendCell(_getCellColor(3, isDark)),
              const SizedBox(width: 2),
              _buildLegendCell(_getCellColor(4, isDark)),
              const SizedBox(width: 4),
              const Text('More', style: TextStyle(fontSize: 8, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCell(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  String _toDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getCellColor(int count, bool isDark) {
    if (count == 0) {
      return isDark ? const Color(0xFF161B22) : const Color(0xFFEBEDF0);
    } else if (count == 1) {
      return isDark ? const Color(0xFF0E4429) : const Color(0xFF9BE9A8);
    } else if (count == 2) {
      return isDark ? const Color(0xFF006D32) : const Color(0xFF40C463);
    } else if (count == 3) {
      return isDark ? const Color(0xFF26A641) : const Color(0xFF30A14E);
    } else {
      return isDark ? const Color(0xFF39D353) : const Color(0xFF216E39);
    }
  }
}
