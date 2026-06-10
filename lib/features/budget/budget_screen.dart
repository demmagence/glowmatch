import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_viewmodel.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetVm = Provider.of<BudgetViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
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
            onPressed: () {},
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
            
            // Spend amount: $342.00
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
                border: Border.all(color: Colors.grey.shade400, width: 1.2),
                borderRadius: BorderRadius.circular(4),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: budgetVm.allocations.map((item) {
                      return Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(item.colorHex)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cost-Per-Apply Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1.2),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'COST-PER-APPLY',
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
                  
                  // Price Input
                  const Text('Product Price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 6),
                  TextField(
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
                    controller: TextEditingController(text: budgetVm.productPrice.toStringAsFixed(2)),
                    onSubmitted: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) budgetVm.updateCalculator(price: parsed);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Estimated Uses Input
                  const Text('Estimated Uses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                  const SizedBox(height: 6),
                  TextField(
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
                    controller: TextEditingController(text: budgetVm.estimatedUses.toString()),
                    onSubmitted: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) budgetVm.updateCalculator(uses: parsed);
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

    // Draw three offset circular rings
    double baseRadius = 55.0;
    double strokeWidth = 8.0;

    for (int i = 0; i < allocations.length; i++) {
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
      // E.g. we draw arcs ending differently (like 3/4 circle, 2/3 circle, 1/2 circle) to look like rings.
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
