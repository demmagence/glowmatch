import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_viewmodel.dart';
import '../../../core/widgets/neobrutalist_card.dart';
import '../../../core/viewmodels/currency_viewmodel.dart';
import 'concentric_rings_painter.dart';

class AllocationCard extends StatelessWidget {
  final bool isDark;
  const AllocationCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final budgetVm = Provider.of<BudgetViewModel>(context);
    final currencyVm = Provider.of<CurrencyViewModel>(context);
    final hasAllocations = budgetVm.allocations.isNotEmpty;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;

    return NeobrutalistCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALLOCATION',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          if (!hasAllocations)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No active products on your shelf to calculate allocations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtextColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: ConcentricRingsPainter(
                    allocations: budgetVm.allocations,
                    isDark: isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${budgetVm.allocations.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: budgetVm.allocations.map((item) {
                final colorHex = item.colorHex;
                final color = Color(int.parse(colorHex));
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.category}: ${currencyVm.formatPrice(item.amount)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
