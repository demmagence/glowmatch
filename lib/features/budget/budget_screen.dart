import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              // Title: Monthly Spend
              Text(
                'MONTHLY SPEND',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 8),

              // Spend amount
              RichText(
                text: TextSpan(
                  text: '\$${budgetVm.totalMonthlySpend.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -1,
                  ),
                  children: [
                    const TextSpan(
                      text: '.',
                      style: TextStyle(color: Colors.pink, fontSize: 54),
                    ),
                    TextSpan(
                      text: '00',
                      style: TextStyle(fontSize: 54, color: textColor),
                    ),
                  ],
                ),
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
                      value: _selectedProductId, // ignore: deprecated_member_use
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
