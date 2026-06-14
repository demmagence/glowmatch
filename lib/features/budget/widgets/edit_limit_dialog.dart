import 'package:flutter/material.dart';
import '../budget_viewmodel.dart';

void showEditLimitDialog(BuildContext context, BudgetViewModel budgetVm) {
  final controller = TextEditingController(
    text: budgetVm.budgetLimit.toStringAsFixed(0),
  );
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final borderColor = isDark ? Colors.white : Colors.black;
  final textColor = isDark ? Colors.white : Colors.black;
  final buttonBg = isDark ? Colors.white : Colors.black;
  final buttonFg = isDark ? Colors.black : Colors.white;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 2),
        ),
        title: Text(
          'Set Monthly Budget Limit',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Budget Limit (\$)',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: textColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBg,
              foregroundColor: buttonFg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: borderColor, width: 1.5),
              ),
            ),
            onPressed: () {
              final limit = double.tryParse(controller.text);
              if (limit != null && limit >= 0) {
                budgetVm.setBudgetLimit(limit);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
