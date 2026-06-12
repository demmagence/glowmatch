import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_viewmodel.dart';
import '../../core/models/models.dart';
import '../profile/profile_screen.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'GLOWMATCH',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            // Spend amount
            RichText(
              text: TextSpan(
                text: '\$${budgetVm.totalMonthlySpend.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
                children: const [
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: Colors.pink, fontSize: 54),
                  ),
                  TextSpan(
                    text: '00',
                    style: TextStyle(fontSize: 54, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Allocation Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.2),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ALLOCATION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${budgetVm.allocations.length}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
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
                                border: Border.all(color: Colors.black, width: 0.8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.category}: \$${item.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.2),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'COST-PER-APPLY CALCULATOR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Icon(Icons.calculate_outlined, size: 22),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product Selection Dropdown
                  const Text('Select Product from Shelf', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedProductId, // ignore: deprecated_member_use
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'custom',
                        child: Text('Custom values (no product)', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                      ...budgetVm.shelfItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.id,
                          child: Text('${item.name} (${item.brand.isEmpty ? 'Unknown Brand' : item.brand})'),
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
                  const Text('Product Price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
                  const Text('Estimated Uses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usesController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
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

                  const Divider(),
                  const SizedBox(height: 16),

                  // Efficiency Metric output
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'EFFICIENCY METRIC',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${budgetVm.efficiencyMetric.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '/ application',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
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
                      color: Colors.grey.shade200,
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
    );
  }
}

// Custom concentric rings painter representing budget allocation categories
class ConcentricRingsPainter extends CustomPainter {
  final List<CategoryAllocation> allocations;

  ConcentricRingsPainter({required this.allocations});

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
        ..color = Colors.grey.shade100;
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
      oldDelegate.allocations != allocations;
}
