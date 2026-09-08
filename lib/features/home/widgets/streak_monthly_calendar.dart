import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:glowmatch/l10n/app_localizations.dart';

class StreakMonthlyCalendar extends StatefulWidget {
  final Set<String> completedSet;

  const StreakMonthlyCalendar({super.key, required this.completedSet});

  @override
  State<StreakMonthlyCalendar> createState() => _StreakMonthlyCalendarState();
}

class _StreakMonthlyCalendarState extends State<StreakMonthlyCalendar> {
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

  String _formatMonthYear(DateTime date, String locale) {
    return DateFormat.yMMMM(locale).format(date);
  }

  String _toDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTooltip(DateTime date, String locale) {
    return DateFormat.yMMMd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final totalDays = _daysInMonth(_focusedMonth);
    final offset = _firstDayWeekdayOffset(_focusedMonth);
    final totalGridItems = offset + totalDays;

    final firstDayOfWeek = DateTime(2023, 1, 1); // Sunday
    final weekdayLabels = List.generate(7, (i) {
      final d = firstDayOfWeek.add(Duration(days: i));
      return DateFormat.E(locale).format(d).substring(0, 1).toUpperCase();
    });

    return GestureDetector(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.visualCalendar,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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
                    _formatMonthYear(_focusedMonth, locale),
                    style: GoogleFonts.poppins(
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
          const SizedBox(height: 12),
          // Weekday Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          // Calendar Grid
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
              final cellDate = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final key = _toDateKey(cellDate);
              final completed = widget.completedSet.contains(key);

              final cellColor = completed
                  ? const Color(0xFF64DD17)
                  : (isDark
                        ? const Color(0xFF424242)
                        : const Color(0xFFE0E0E0));

              final cellTextColor = completed
                  ? Colors.black87
                  : (isDark ? Colors.white60 : Colors.black54);

              return Tooltip(
                message:
                    '${_formatDateTooltip(cellDate, locale)}: ${completed ? l10n.completed : l10n.missed}',
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cellColor,
                    border: Border.all(
                      color: isDark ? Colors.white : Colors.black,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: cellTextColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
