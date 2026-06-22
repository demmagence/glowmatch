import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/neobrutalist_card.dart';
import '../../../core/viewmodels/currency_viewmodel.dart';
import '../shelf_viewmodel.dart';
import 'product_image.dart';
import 'product_details_sheet.dart';
import 'delete_confirmation_dialog.dart';

class ProductCard extends StatelessWidget {
  final ShelfItem item;
  final ShelfViewModel shelfVm;

  const ProductCard({super.key, required this.item, required this.shelfVm});

  @override
  Widget build(BuildContext context) {
    final currencyVm = Provider.of<CurrencyViewModel>(context);
    final colorHex = item.indicatorColor;
    final dotColor = Color(int.parse(colorHex));
    final int estimatedUses = item.estimatedUses;
    final int remainingUses = item.remainingUses;
    final double price = item.price;
    final bool isEmpty = remainingUses <= 0;
    final double progress = estimatedUses > 0
        ? (remainingUses / estimatedUses).clamp(0.0, 1.0)
        : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final imageBg = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final borderSideColor = isDark ? Colors.white30 : Colors.black;

    return NeobrutalistCard(
      onTap: () => showProductDetailsBottomSheet(context, item, shelfVm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: imageBg,
                    border: Border(
                      bottom: BorderSide(color: borderSideColor, width: 1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                    child: buildProductImage(item.imageUrl),
                  ),
                ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      currencyVm.formatPrice(price),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => showDeleteConfirmation(context, item, shelfVm),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: textColor, width: 1),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                ),

                if (isEmpty)
                  Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.65),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: textColor, width: 1.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'FINISHED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: subtextColor),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    color: dotColor,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$remainingUses/$estimatedUses left',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isEmpty ? Colors.red : subtextColor,
                      ),
                    ),
                    if (!isEmpty)
                      GestureDetector(
                        onTap: () {
                          shelfVm.useProduct(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Used 1 apply of ${item.name}!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: isDark
                                  ? Colors.grey.shade900
                                  : Colors.black,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: textColor,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: textColor, width: 1),
                          ),
                          child: Text(
                            'USE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.black : Colors.white,
                            ),
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
    );
  }
}
