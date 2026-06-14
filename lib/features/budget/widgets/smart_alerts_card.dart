import 'package:flutter/material.dart';
import '../budget_viewmodel.dart';
import '../../../core/widgets/neobrutalist_card.dart';

class SmartAlertsCard extends StatelessWidget {
  final bool isDark;
  final BudgetViewModel budgetVm;

  const SmartAlertsCard({
    super.key,
    required this.isDark,
    required this.budgetVm,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;

    return NeobrutalistCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SMART ALERTS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textColor,
                ),
              ),
              Icon(
                Icons.notifications_active_outlined,
                size: 22,
                color: textColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (budgetVm.smartAlerts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.teal.shade900.withValues(alpha: 0.2)
                    : Colors.teal.shade50,
                border: Border.all(
                  color: isDark ? Colors.teal.shade300 : Colors.teal.shade800,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: isDark ? Colors.teal.shade300 : Colors.teal.shade800,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All budgets healthy! No alerts.',
                    style: TextStyle(
                      color: isDark
                          ? Colors.teal.shade300
                          : Colors.teal.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgetVm.smartAlerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = budgetVm.smartAlerts[index];

                Color alertBg;
                Color alertBorderColor;
                Color alertTextColor;
                IconData alertIcon;

                if (alert.type == 'danger') {
                  alertBg = isDark
                      ? Colors.red.shade900.withValues(alpha: 0.2)
                      : Colors.red.shade50;
                  alertBorderColor = isDark
                      ? Colors.red.shade300
                      : Colors.red.shade800;
                  alertTextColor = isDark
                      ? Colors.red.shade300
                      : Colors.red.shade800;
                  alertIcon = Icons.error_outline;
                } else if (alert.type == 'warning') {
                  alertBg = isDark
                      ? Colors.amber.shade900.withValues(alpha: 0.2)
                      : Colors.amber.shade50;
                  alertBorderColor = isDark
                      ? Colors.amber.shade300
                      : Colors.amber.shade800;
                  alertTextColor = isDark
                      ? Colors.amber.shade300
                      : Colors.amber.shade800;
                  alertIcon = Icons.warning_amber_outlined;
                } else {
                  alertBg = isDark
                      ? Colors.blue.shade900.withValues(alpha: 0.2)
                      : Colors.blue.shade50;
                  alertBorderColor = isDark
                      ? Colors.blue.shade300
                      : Colors.blue.shade800;
                  alertTextColor = isDark
                      ? Colors.blue.shade300
                      : Colors.blue.shade800;
                  alertIcon = Icons.info_outline;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: alertBg,
                    border: Border.all(color: alertBorderColor, width: 1.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(alertIcon, color: alertTextColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: alertTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: alertTextColor.withValues(alpha: 0.95),
                              ),
                            ),
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
    );
  }
}
