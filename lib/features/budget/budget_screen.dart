import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_viewmodel.dart';
import '../../core/models/models.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/loading_overlay.dart';
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
  @override
  Widget build(BuildContext context) {
    final budgetVm = Provider.of<BudgetViewModel>(context);
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
                    onPressed: () => showEditLimitDialog(context, budgetVm),
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
              AllocationCard(isDark: isDark),
              const SizedBox(height: 24),

              // Spending History Card
              SpendingHistoryCard(
                isDark: isDark,
                budgetVm: budgetVm,
              ),
              const SizedBox(height: 24),

              // Smart Alerts Card
              SmartAlertsCard(
                isDark: isDark,
                budgetVm: budgetVm,
              ),
              const SizedBox(height: 24),

              // Cost-Per-Apply Card
              CalculatorCard(
                isDark: isDark,
                selectedProductId: _selectedProductId,
                priceController: _priceController,
                usesController: _usesController,
                onProductChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedProductId = val; });
                    if (val != 'custom') {
                      final prod = budgetVm.shelfItems.firstWhere((x) => x.id == val);
                      _syncControllersWithProduct(prod, budgetVm);
                    }
                  }
                },
                onPriceChanged: (val) {
                  setState(() { _selectedProductId = 'custom'; });
                  final parsed = double.tryParse(val);
                  if (parsed != null) budgetVm.updateCalculator(price: parsed);
                },
                onUsesChanged: (val) {
                  setState(() { _selectedProductId = 'custom'; });
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
}

