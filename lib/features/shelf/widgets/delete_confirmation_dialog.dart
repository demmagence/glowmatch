import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../shelf_viewmodel.dart';

  void showDeleteConfirmation(BuildContext context, ShelfItem item, ShelfViewModel shelfVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          title: Text('Delete Product?', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: Text(
            'Are you sure you want to delete ${item.name} from your shelf?',
            style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                shelfVm.deleteProduct(item.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${item.name}'),
                    backgroundColor: isDark ? Colors.grey.shade900 : Colors.black,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }