import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_viewmodel.dart';
import '../../core/models/models.dart';
import '../../core/widgets/glowmatch_header.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/viewmodels/currency_viewmodel.dart';
import 'widgets/allocation_card.dart';
import 'widgets/calculator_card.dart';
import 'widgets/spending_history_card.dart';

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
              Text(
                'TOTAL SPEND IN PERIOD',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                currencyVm.formatPrice(budgetVm.totalMonthlySpend),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: borderColor, width: 2),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPeriodToggleItem(
                        context,
                        label: '30 Days',
                        isActive: budgetVm.selectedPeriodDays == 30,
                        onTap: () => budgetVm.setPeriodDays(30),
                      ),
                    ),
                    Expanded(
                      child: _buildPeriodToggleItem(
                        context,
                        label: '90 Days',
                        isActive: budgetVm.selectedPeriodDays == 90,
                        onTap: () => budgetVm.setPeriodDays(90),
                      ),
                    ),
                    Expanded(
                      child: _buildPeriodToggleItem(
                        context,
                        label: 'All Time',
                        isActive: budgetVm.selectedPeriodDays == 0,
                        onTap: () => budgetVm.setPeriodDays(0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              AllocationCard(isDark: isDark),
              const SizedBox(height: 24),

              SpendingHistoryCard(isDark: isDark, budgetVm: budgetVm),
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

  Widget _buildPeriodToggleItem(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final activeTextColor = isDark ? Colors.black : Colors.white;
    final inactiveTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? activeTextColor : inactiveTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

