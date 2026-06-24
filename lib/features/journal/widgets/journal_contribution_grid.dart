import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

class JournalContributionGrid extends StatefulWidget {
  final List<JournalEntry> entries;

  const JournalContributionGrid({
    super.key,
    required this.entries,
  });

  @override
  State<JournalContributionGrid> createState() => _JournalContributionGridState();
}

class _JournalContributionGridState extends State<JournalContributionGrid> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  int _daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));
    return lastDay.day;
  }

  int _firstDayWeekdayOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    // Sunday: 7 % 7 = 0
    // Monday: 1 % 7 = 1
    // ...
    // Saturday: 6 % 7 = 6
    return firstDay.weekday % 7;
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
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

  Color _getCellTextColor(int count, bool isDark) {
    if (count == 0) {
      return isDark ? Colors.white60 : Colors.black54;
    }
    if (isDark) {
      // level 4 (count >= 4) is bright green Color(0xFF39D353), use black text for readability
      return count >= 4 ? Colors.black87 : Colors.white;
    } else {
      // level 3/4 are dark green, use white text for readability
      return count >= 3 ? Colors.white : Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? Colors.grey.shade900 : Colors.white;
    final shadowColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black;

    // Map entries to days for quick lookup
    final Map<String, int> entryCounts = {};
    for (final entry in widget.entries) {
      if (entry.createdAt != null) {
        final dateKey = _toDateKey(entry.createdAt!);
        entryCounts[dateKey] = (entryCounts[dateKey] ?? 0) + 1;
      }
    }

    final totalDays = _daysInMonth(_focusedMonth);
    final offset = _firstDayWeekdayOffset(_focusedMonth);
    final totalGridItems = offset + totalDays;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

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
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _nextMonth();
            } else if (details.primaryVelocity! > 0) {
              _prevMonth();
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Glow Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _prevMonth,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatMonthYear(_focusedMonth),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _nextMonth,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weekday Headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdayLabels.map((label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            // Monthly Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: totalGridItems,
              itemBuilder: (context, index) {
                if (index < offset) {
                  return const SizedBox();
                }
                final day = index - offset + 1;
                final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                final dateKey = _toDateKey(cellDate);
                final count = entryCounts[dateKey] ?? 0;
                final cellColor = _getCellColor(count, isDark);
                final cellTextColor = _getCellTextColor(count, isDark);

                final countText = count == 0 ? 'no entries' : (count == 1 ? '1 entry' : '$count entries');
                final formattedDate = '${months[cellDate.month - 1]} ${cellDate.day}, ${cellDate.year}';
                final tooltipMessage = '$countText on $formattedDate';

                return Tooltip(
                  message: tooltipMessage,
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cellTextColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Legend
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
}
