import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_viewmodel.dart';
import '../../../core/widgets/neobrutalist_card.dart';
import '../../../core/viewmodels/currency_viewmodel.dart';

class CalculatorCard extends StatelessWidget {
  final bool isDark;
  final String selectedProductId;
  final TextEditingController priceController;
  final TextEditingController usesController;
  final Function(String?) onProductChanged;
  final Function(String) onPriceChanged;
  final Function(String) onUsesChanged;

  const CalculatorCard({
    super.key,
    required this.isDark,
    required this.selectedProductId,
    required this.priceController,
    required this.usesController,
    required this.onProductChanged,
    required this.onPriceChanged,
    required this.onUsesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final budgetVm = Provider.of<BudgetViewModel>(context);
    final currencyVm = Provider.of<CurrencyViewModel>(context);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;

    return NeobrutalistCard(
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

          Text(
            'Select Product from Shelf',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedProductId,
            dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
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
                child: Text(
                  'Custom values (no product)',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                ),
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
            onChanged: onProductChanged,
          ),
          const SizedBox(height: 16),

          Text(
            'Product Price',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: priceController,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: '${currencyVm.currencySymbol} ',
              prefixStyle: TextStyle(color: textColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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
            onChanged: onPriceChanged,
          ),
          const SizedBox(height: 16),

          Text(
            'Estimated Uses',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: usesController,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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
            onChanged: onUsesChanged,
          ),
          const SizedBox(height: 24),

          Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),

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
                    currencyVm.formatPrice(budgetVm.efficiencyMetric),
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

          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (1.5 / (budgetVm.efficiencyMetric + 0.1)).clamp(
                0.1,
                1.0,
              ),
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
    );
  }
}
