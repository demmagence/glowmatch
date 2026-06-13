import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'budget_viewmodel.dart';
import '../../core/models/models.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/neobrutalist_card.dart';
import '../../core/widgets/loading_overlay.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late TextEditingController _priceController;
  late TextEditingController _usesController;
  String _selectedProductId = 'custom';

  @override
  void initState() {
    super.initState();
    final budgetVm = Provider.of<BudgetViewModel>(context, listen: false);
    budgetVm.loadBudgetLimit();
    _priceController = TextEditingController(text: budgetVm.productPrice.toStringAsFixed(2));
    _usesController = TextEditingController(text: budgetVm.estimatedUses.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _usesController.dispose();
    super.dispose();
  }

  void _syncControllersWithProduct(ShelfItem product, BudgetViewModel budgetVm) {
    final double price = product.price;
    final int uses = product.estimatedUses;
    
    setState(() {
      _priceController.text = price.toStringAsFixed(2);
      _usesController.text = uses.toString();
    });
    budgetVm.updateCalculator(price: price, uses: uses);
  }

  void _showEditLimitDialog(BuildContext context, BudgetViewModel budgetVm) {
    final controller = TextEditingController(text: budgetVm.budgetLimit.toStringAsFixed(0));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonBg = isDark ? Colors.white : Colors.black;
    final buttonFg = isDark ? Colors.black : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          title: Text(
            'Set Monthly Budget Limit',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Budget Limit (\$)',
              labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              prefixText: '\$ ',
              prefixStyle: TextStyle(color: textColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: buttonFg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: borderColor, width: 1.5),
                ),
              ),
              onPressed: () {
                final limit = double.tryParse(controller.text);
                if (limit != null && limit >= 0) {
                  budgetVm.setBudgetLimit(limit);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetVm = Provider.of<BudgetViewModel>(context);
    final hasAllocations = budgetVm.allocations.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: 'GlowMatch',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: textColor,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(
                text: '.',
                style: TextStyle(color: Colors.red, fontSize: 26),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: budgetVm.isLoading,
        message: 'Calculating budget...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title: Monthly Spend vs Limit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MONTHLY SPEND vs LIMIT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: subtextColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showEditLimitDialog(context, budgetVm),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Spend vs Limit amount
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${budgetVm.totalMonthlySpend.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    ' / \$${budgetVm.budgetLimit.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Budget Limit Progress Bar
              Builder(
                builder: (context) {
                  final spend = budgetVm.totalMonthlySpend;
                  final limit = budgetVm.budgetLimit;
                  final percent = limit > 0 ? (spend / limit).clamp(0.0, 1.0) : 1.0;
                  final isOverBudget = spend > limit;
                  final progressColor = isOverBudget ? const Color(0xFFD50000) : const Color(0xFF64DD17);

                  return Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      border: Border.all(color: borderColor, width: 1.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: percent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Allocation Card
              NeobrutalistCard(
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
                              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
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
                      // Concentric Ring Canvas Chart
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

                      // Category Legend
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
                                '${item.category}: \$${item.amount.toStringAsFixed(0)}',
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
              ),
              const SizedBox(height: 24),

              // Spending History Card
              NeobrutalistCard(
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
                          maxY: (budgetVm.spendingHistory.reduce(max) * 1.25).clamp(100.0, 999999.0),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: isDark ? Colors.grey.shade900 : Colors.black,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final label = budgetVm.spendingHistoryLabels[group.x.toInt()];
                                return BarTooltipItem(
                                  '$label\n\$${rod.toY.toStringAsFixed(0)}',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '\$${value.toInt()}',
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
                                  if (idx >= 0 && idx < budgetVm.spendingHistoryLabels.length) {
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
                          barGroups: List.generate(budgetVm.spendingHistory.length, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: budgetVm.spendingHistory[index],
                                  color: isDark ? Colors.pink.shade300 : Colors.pinkAccent,
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
              ),
              const SizedBox(height: 24),

              // Smart Alerts Card
              NeobrutalistCard(
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
                        Icon(Icons.notifications_active_outlined, size: 22, color: textColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (budgetVm.smartAlerts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.teal.shade900.withValues(alpha: 0.2) : Colors.teal.shade50,
                          border: Border.all(color: isDark ? Colors.teal.shade300 : Colors.teal.shade800, width: 1.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: isDark ? Colors.teal.shade300 : Colors.teal.shade800, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'All budgets healthy! No alerts.',
                              style: TextStyle(
                                color: isDark ? Colors.teal.shade300 : Colors.teal.shade800,
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
                            alertBg = isDark ? Colors.red.shade900.withValues(alpha: 0.2) : Colors.red.shade50;
                            alertBorderColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
                            alertTextColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
                            alertIcon = Icons.error_outline;
                          } else if (alert.type == 'warning') {
                            alertBg = isDark ? Colors.amber.shade900.withValues(alpha: 0.2) : Colors.amber.shade50;
                            alertBorderColor = isDark ? Colors.amber.shade300 : Colors.amber.shade800;
                            alertTextColor = isDark ? Colors.amber.shade300 : Colors.amber.shade800;
                            alertIcon = Icons.warning_amber_outlined;
                          } else {
                            alertBg = isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50;
                            alertBorderColor = isDark ? Colors.blue.shade300 : Colors.blue.shade800;
                            alertTextColor = isDark ? Colors.blue.shade300 : Colors.blue.shade800;
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
              ),
              const SizedBox(height: 24),

              // Cost-Per-Apply Card
              NeobrutalistCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COST-PER-APPLY CALCULATOR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: textColor,
                          ),
                        ),
                        Icon(Icons.calculate_outlined, size: 22, color: textColor),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Selection Dropdown
                    Text('Select Product from Shelf', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subtextColor)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedProductId,
                      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'custom',
                          child: Text('Custom values (no product)', style: TextStyle(fontStyle: FontStyle.italic, color: textColor)),
                        ),
                        ...budgetVm.shelfItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(
                              '${item.name} (${item.brand.isEmpty ? 'Unknown Brand' : item.brand})',
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedProductId = val;
                          });
                          if (val != 'custom') {
                            final prod = budgetVm.shelfItems.firstWhere((x) => x.id == val);
                            _syncControllersWithProduct(prod, budgetVm);
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price Input
                    Text('Product Price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subtextColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _priceController,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: textColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        setState(() {
                          _selectedProductId = 'custom';
                        });
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          budgetVm.updateCalculator(price: parsed);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estimated Uses Input
                    Text('Estimated Uses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subtextColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usesController,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {
                          _selectedProductId = 'custom';
                        });
                        final parsed = int.tryParse(val);
                        if (parsed != null) {
                          budgetVm.updateCalculator(uses: parsed);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    const SizedBox(height: 16),

                    // Efficiency Metric output
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'EFFICIENCY METRIC',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: subtextColor,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${budgetVm.efficiencyMetric.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '/ application',
                              style: TextStyle(
                                fontSize: 11,
                                color: subtextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Efficiency Bar
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (1.5 / (budgetVm.efficiencyMetric + 0.1)).clamp(0.1, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink.shade500,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom concentric rings painter representing budget allocation categories
class ConcentricRingsPainter extends CustomPainter {
  final List<CategoryAllocation> allocations;
  final bool isDark;

  ConcentricRingsPainter({required this.allocations, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double baseRadius = 45.0;
    double strokeWidth = 8.0;
    int count = min(allocations.length, 4);

    for (int i = 0; i < count; i++) {
      final item = allocations[i];
      final color = Color(int.parse(item.colorHex));
      final radius = baseRadius + (i * 14.0);

      paint.color = color;
      paint.strokeWidth = strokeWidth;

      // Draw background track line
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100;
      canvas.drawCircle(center, radius, trackPaint);

      // Draw active circular arc.
      double startAngle = -pi / 2;
      double sweepAngle = (1.8 - (i * 0.4)) * pi; // varying length of ring

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConcentricRingsPainter oldDelegate) =>
      oldDelegate.allocations != allocations || oldDelegate.isDark != isDark;
}
