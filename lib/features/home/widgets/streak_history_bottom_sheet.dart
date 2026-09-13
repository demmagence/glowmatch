import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:glowmatch/l10n/app_localizations.dart';
import '../routine_viewmodel.dart';
import 'streak_monthly_calendar.dart';

class StreakHistoryBottomSheet extends StatelessWidget {
  const StreakHistoryBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StreakHistoryBottomSheet(),
    );
  }

  String _formatDate(DateTime date, String locale) {
    return DateFormat.yMMMd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final routineVm = Provider.of<RoutineViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final completedSet = routineVm.dailyCompletionLogs
        .map(
          (d) =>
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        )
        .toSet();

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: borderColor, width: 2.5),
          left: BorderSide(color: borderColor, width: 2.5),
          right: BorderSide(color: borderColor, width: 2.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle or top bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.streakHistoryAndStats,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black,
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 18, color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.currentStreak,
                    l10n.streakDaysCount(
                      routineVm.streakData?.currentStreak ?? 0,
                    ),
                    '🔥',
                    context,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    l10n.longestStreak,
                    l10n.streakDaysCount(
                      routineVm.streakData?.longestStreak ?? 0,
                    ),
                    '👑',
                    context,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    l10n.totalCompleted,
                    '${routineVm.streakData?.totalCompletions ?? 0}',
                    '🏆',
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly visual calendar for streaks
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFFAFAFA),
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  StreakMonthlyCalendar(completedSet: completedSet),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        const Color(0xFF64DD17),
                        l10n.completed,
                        context,
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        isDark
                            ? const Color(0xFF424242)
                            : const Color(0xFFE0E0E0),
                        l10n.missed,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Historical Streak List Section
            Text(
              l10n.streakHistory,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            if (routineVm.streakSegments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: 1.2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? const Color(0xFF2B2B2B)
                      : const Color(0xFFFAFAFA),
                ),
                child: Text(
                  l10n.noStreakHistoryYet,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: routineVm.streakSegments.length,
                itemBuilder: (context, index) {
                  final segment = routineVm.streakSegments[index];
                  final isMilestone = segment.length >= 7;
                  final badgeBg = isMilestone
                      ? const Color(0xFFFFD54F)
                      : (isDark
                            ? const Color(0xFF333333)
                            : const Color(0xFFEEEEEE));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            border: Border.all(color: borderColor, width: 1.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.streakDaysCount(segment.length),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w900,
                              color: isMilestone ? Colors.black : textColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatDate(segment.startDate, locale)} - ${_formatDate(segment.endDate, locale)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              if (isMilestone) ...[
                                const SizedBox(height: 2),
                                Text(
                                  segment.length >= 30
                                      ? l10n.skincareMasterMilestone
                                      : segment.length >= 14
                                      ? l10n.unstoppableBarrierMilestone
                                      : l10n.solidHabitMilestone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFFFFD54F)
                                        : const Color(0xFFD3A200),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String icon,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFAFAFA);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: isDark ? Colors.white : Colors.black,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
