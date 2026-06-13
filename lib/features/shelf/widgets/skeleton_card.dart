import 'package:flutter/material.dart';
import '../../../core/widgets/neobrutalist_card.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final block1 = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final block2 = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;

    return NeobrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: bg,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  color: block1,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 10,
                  color: block2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}