import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../budget_viewmodel.dart';
import '../../../core/widgets/neobrutalist_card.dart';
import '../../../core/viewmodels/currency_viewmodel.dart';

class SpendingHistoryCard extends StatelessWidget {
  final bool isDark;
  final BudgetViewModel budgetVm;

  const SpendingHistoryCard({
    super.key,
    required this.isDark,
    required this.budgetVm,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final currencyVm = Provider.of<CurrencyViewModel>(context);
    
    final historyInSelectedCurrency = budgetVm.spendingHistory
        .map((val) => currencyVm.convertFromIDR(val))
        .toList();

    return NeobrutalistCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING HISTORY (LAST 6 MONTHS)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (historyInSelectedCurrency.reduce(max) * 1.25).clamp(
                  1.0,
                  999999999.0,
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: isDark
                        ? Colors.grey.shade900
                        : Colors.black,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label =
                          budgetVm.spendingHistoryLabels[group.x.toInt()];
                      final valInIDR = currencyVm.convertToIDR(rod.toY);
                      return BarTooltipItem(
                        '$label\n${currencyVm.formatPrice(valInIDR)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.white10 : const Color(0xFFEEEEEE),
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 1.5),
                    left: BorderSide(color: borderColor, width: 1.5),
                    top: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${currencyVm.currencySymbol}${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 &&
                            idx < budgetVm.spendingHistoryLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              budgetVm.spendingHistoryLabels[idx],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(historyInSelectedCurrency.length, (
                  index,
                ) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: historyInSelectedCurrency[index],
                        color: isDark
                            ? Colors.pink.shade300
                            : Colors.pinkAccent,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: borderColor, width: 1.2),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
