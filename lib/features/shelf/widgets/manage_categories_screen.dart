import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/viewmodels/auth_viewmodel.dart';
import '../shelf_viewmodel.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _nameController = TextEditingController();
  String _selectedColor = '0xFFE040FB';

  static const List<String> _colorOptions = [
    '0xFFE040FB', // Purple
    '0xFF64DD17', // Green
    '0xFFD50000', // Red
    '0xFF29B6F6', // Light Blue
    '0xFFFFD600', // Yellow
    '0xFFFF6D00', // Orange
    '0xFF00BFA5', // Teal
    '0xFFFF4081', // Pink
    '0xFF3F51B5', // Indigo
    '0xFF9C27B0', // Dark Purple
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addCategory(String userId, ShelfViewModel vm) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Check if name matches existing categories
    final exists = vm.categories.any(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name already exists!')),
      );
      return;
    }

    vm.addCustomCategory(
      userId: userId,
      name: name,
      colorHex: _selectedColor,
    );
    _nameController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showEditDialog(
    BuildContext context,
    ShelfViewModel vm,
    SkincareCategory category,
  ) {
    final editController = TextEditingController(text: category.name);
    String editColor = category.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              title: Text(
                'Rename Category',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: editController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
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
                  const SizedBox(height: 20),
                  Text(
                    'Choose Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((hex) {
                      final color = Color(int.parse(hex));
                      final isSelected = editColor == hex;
                      return GestureDetector(
                        onTap: () => setDialogState(() => editColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? borderColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(color: borderColor, width: 1.5),
                    ),
                  ),
                  onPressed: () {
                    final name = editController.text.trim();
                    if (name.isNotEmpty) {
                      vm.renameCustomCategory(
                        categoryId: category.id,
                        newName: name,
                        colorHex: editColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCategoryWithWarning(
    BuildContext context,
    ShelfViewModel vm,
    SkincareCategory category,
  ) {
    final inUseCount = vm.shelfItems.where((x) => x.category == category.name).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

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
            'Delete Category',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: Text(
            inUseCount > 0
                ? 'Warning: There are $inUseCount product(s) currently using "${category.name}". Deleting this category will reassign them to the default category "Serum". Are you sure you want to delete?'
                : 'Are you sure you want to delete the category "${category.name}"?',
            style: TextStyle(color: textColor),
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: borderColor, width: 1.5),
                ),
              ),
              onPressed: () {
                vm.deleteCustomCategory(category.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category "${category.name}" deleted.')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ShelfViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBg = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final shadow = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Category Box (Neobrutalist)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(color: shadow, offset: const Offset(4, 4), blurRadius: 0),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Category Name (e.g. Essence)',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Category Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((hex) {
                      final color = Color(int.parse(hex));
                      final isSelected = _selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? borderColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: borderColor, width: 1.5),
                        ),
                      ),
                      onPressed: () => _addCategory(authVm.userId, vm),
                      child: const Text(
                        'ADD CATEGORY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'All Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = vm.categories[index];
                final color = Color(int.parse(category.color));

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      if (category.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: isDark ? Colors.white70 : Colors.black54,
                              onPressed: () => _showEditDialog(context, vm, category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _deleteCategoryWithWarning(context, vm, category),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
