import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_viewmodel.dart';
import '../../core/models/models.dart';
import '../../core/widgets/glowmatch_header.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/viewmodels/currency_viewmodel.dart';
import 'widgets/allocation_card.dart';
import 'widgets/calculator_card.dart';
import 'widgets/edit_limit_dialog.dart';
import 'widgets/spending_history_card.dart';
import 'widgets/smart_alerts_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late TextEditingController _priceController;
  late TextEditingController _usesController;
  String _selectedProductId = 'custom';
  String? _previousCurrency;

  @override
  void initState() {
    super.initState();
    final budgetVm = Provider.of<BudgetViewModel>(context, listen: false);
    budgetVm.loadBudgetLimit();
    _priceController = TextEditingController(text: '');
    _usesController = TextEditingController(
      text: budgetVm.estimatedUses.toString(),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _usesController.dispose();
    super.dispose();
  }

  void _syncControllersWithProduct(
    ShelfItem product,
    BudgetViewModel budgetVm,
    CurrencyViewModel currencyVm,
  ) {
    final double price = product.price;
    final int uses = product.estimatedUses;

    setState(() {
      _priceController.text = currencyVm.formatPriceWithoutSymbol(price);
      _usesController.text = uses.toString();
    });
    budgetVm.updateCalculator(price: price, uses: uses);
  }

  @override
  Widget build(BuildContext context) {
    final budgetVm = Provider.of<BudgetViewModel>(context);
    final currencyVm = Provider.of<CurrencyViewModel>(context);
    
    // Sync price controller if currency changes
    if (_previousCurrency != currencyVm.selectedCurrency) {
      _previousCurrency = currencyVm.selectedCurrency;
      _priceController.text = currencyVm.formatPriceWithoutSymbol(budgetVm.productPrice);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: budgetVm.isLoading,
        message: 'Calculating budget...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const GlowMatchHeader(),
              const SizedBox(height: 24),
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
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: subtextColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => showEditLimitDialog(context, budgetVm),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currencyVm.formatPrice(budgetVm.totalMonthlySpend),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -1,
                    ),
                  ),
                  if (budgetVm.selectedPeriod != 'all')
                    Text(
                      ' / ${currencyVm.formatPrice(budgetVm.selectedPeriod == '90' ? budgetVm.budgetLimit * 3 : budgetVm.budgetLimit)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: subtextColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Period Selector Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPeriodTab(context, budgetVm, '30', '30 Days'),
                  const SizedBox(width: 8),
                  _buildPeriodTab(context, budgetVm, '90', '90 Days'),
                  const SizedBox(width: 8),
                  _buildPeriodTab(context, budgetVm, 'all', 'All-Time'),
                ],
              ),
              const SizedBox(height: 20),

              if (budgetVm.selectedPeriod != 'all') ...[
                Builder(
                  builder: (context) {
                    final spend = budgetVm.totalMonthlySpend;
                    final limit = budgetVm.selectedPeriod == '90'
                        ? budgetVm.budgetLimit * 3
                        : budgetVm.budgetLimit;
                    final percent = limit > 0
                        ? (spend / limit).clamp(0.0, 1.0)
                        : 1.0;
                    final isOverBudget = spend > limit;
                    final progressColor = isOverBudget
                        ? const Color(0xFFD50000)
                        : const Color(0xFF64DD17);

                    return Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
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
              ],

              AllocationCard(isDark: isDark),
              const SizedBox(height: 24),

              SpendingHistoryCard(isDark: isDark, budgetVm: budgetVm),
              const SizedBox(height: 24),

              SmartAlertsCard(isDark: isDark, budgetVm: budgetVm),
              const SizedBox(height: 24),

              CalculatorCard(
                isDark: isDark,
                selectedProductId: _selectedProductId,
                priceController: _priceController,
                usesController: _usesController,
                onProductChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedProductId = val;
                    });
                    if (val != 'custom') {
                      final prod = budgetVm.shelfItems.firstWhere(
                        (x) => x.id == val,
                      );
                      _syncControllersWithProduct(prod, budgetVm, currencyVm);
                    }
                  }
                },
                onPriceChanged: (val) {
                  setState(() {
                    _selectedProductId = 'custom';
                  });
                  final parsed = double.tryParse(val);
                  if (parsed != null) {
                    budgetVm.updateCalculator(
                      price: currencyVm.convertToIDR(parsed),
                    );
                  }
                },
                onUsesChanged: (val) {
                  setState(() {
                    _selectedProductId = 'custom';
                  });
                  final parsed = int.tryParse(val);
                  if (parsed != null) budgetVm.updateCalculator(uses: parsed);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTab(
    BuildContext context,
    BudgetViewModel budgetVm,
    String period,
    String label,
  ) {
    final isSelected = budgetVm.selectedPeriod == period;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    final activeBg = isDark ? Colors.pinkAccent : Colors.yellowAccent;
    final inactiveBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final activeText = isDark ? Colors.white : Colors.black;
    final inactiveText = isDark ? Colors.grey.shade400 : Colors.black;

    return GestureDetector(
      onTap: () => budgetVm.setSelectedPeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black,
                    offset: const Offset(2, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}
