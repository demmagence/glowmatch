import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../shelf_viewmodel.dart';
import 'product_image.dart';
import 'edit_product_dialog.dart';
import 'delete_confirmation_dialog.dart';

Widget buildDetailMetric(BuildContext context, String label, String value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    ],
  );
}

void showProductDetailsBottomSheet(
  BuildContext context,
  ShelfItem item,
  ShelfViewModel shelfVm,
) {
  final colorHex = item.indicatorColor;
  final dotColor = Color(int.parse(colorHex));
  final int estimatedUses = item.estimatedUses;
  final int remainingUses = item.remainingUses;
  final double price = item.price;
  final double costPerApply = estimatedUses > 0 ? price / estimatedUses : 0.0;
  final List<String> ingredients = item.ingredients;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  final bottomSheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final handleColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  final imageBg = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
  final borderSideColor = isDark ? Colors.white30 : Colors.black;
  final chipBg = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
  final chipBorderColor = isDark ? Colors.white10 : Colors.grey.shade300;
  final ingredientTextColor = isDark ? Colors.white70 : Colors.black87;
  final buttonBg = isDark ? Colors.white : Colors.black;
  final buttonFg = isDark ? Colors.black : Colors.white;

  showModalBottomSheet(
    context: context,
    backgroundColor: bottomSheetBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: imageBg,
                    border: Border.all(color: borderSideColor, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: buildProductImage(item.imageUrl),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.brand,
                        style: TextStyle(fontSize: 16, color: subtextColor),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: dotColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: dotColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildDetailMetric(
                  context,
                  'PRICE',
                  '\$${price.toStringAsFixed(2)}',
                ),
                buildDetailMetric(
                  context,
                  'USES REMAINING',
                  '$remainingUses / $estimatedUses',
                ),
                buildDetailMetric(
                  context,
                  'COST PER USE',
                  '\$${costPerApply.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'INGREDIENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ingredients.isEmpty
                ? Text(
                    'No ingredients listed.',
                    style: TextStyle(color: subtextColor, fontSize: 13),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ingredients.map((ing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: chipBorderColor,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          ing,
                          style: TextStyle(
                            fontSize: 12,
                            color: ingredientTextColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: textColor, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showEditProductDialog(context, item, shelfVm);
                    },
                    child: const Text(
                      'EDIT PRODUCT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDeleteConfirmation(context, item, shelfVm);
                    },
                    child: const Text(
                      'DELETE PRODUCT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: buttonFg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: borderSideColor, width: 1.5),
                  ),
                ),
                onPressed: remainingUses > 0
                    ? () {
                        shelfVm.useProduct(item.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Used 1 apply of ${item.name}!'),
                            backgroundColor: isDark
                                ? Colors.grey.shade900
                                : Colors.black,
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'USE PRODUCT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
