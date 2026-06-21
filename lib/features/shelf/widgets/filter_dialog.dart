import 'package:flutter/material.dart';
import '../shelf_viewmodel.dart';

void showFilterDialog(BuildContext context, ShelfViewModel vm) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final borderColor = isDark ? Colors.white : Colors.black;
  final textColor = isDark ? Colors.white : Colors.black;

  showDialog(
    context: context,
    builder: (context) {
      final categories = [
        'All',
        ...vm.categories.map((e) => e.name),
      ];
      return SimpleDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 2),
        ),
        title: Text(
          'Filter by Category',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        children: categories.map((category) {
          final isSelected = vm.selectedCategoryFilter == category;
          return SimpleDialogOption(
            onPressed: () {
              vm.setFilter(category);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                category,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? Colors.pinkAccent : Colors.pink)
                      : textColor,
                ),
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
