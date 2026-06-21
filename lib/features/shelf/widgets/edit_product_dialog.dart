import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/viewmodels/auth_viewmodel.dart';
import '../shelf_viewmodel.dart';
import 'product_image.dart';

void showEditProductDialog(
  BuildContext context,
  ShelfItem item,
  ShelfViewModel vm,
) {
  final nameController = TextEditingController(text: item.name);
  final brandController = TextEditingController(text: item.brand);
  final priceController = TextEditingController(text: item.price.toString());
  final usesController = TextEditingController(
    text: item.estimatedUses.toString(),
  );
  final remainingUsesController = TextEditingController(
    text: item.remainingUses.toString(),
  );
  final sizeController = TextEditingController(text: item.productSize);
  final ingredientsController = TextEditingController(
    text: item.ingredients.join(', '),
  );
  String selectedCategory = item.category;
  String? localImagePath;

  final ImagePicker picker = ImagePicker();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final borderColor = isDark ? Colors.white : Colors.black;
  final textColor = isDark ? Colors.white : Colors.black;
  final buttonBg = isDark ? Colors.white : Colors.black;
  final buttonFg = isDark ? Colors.black : Colors.white;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final userId = Provider.of<AuthViewModel>(
            context,
            listen: false,
          ).userId;

          Future<void> pickImage(ImageSource source) async {
            try {
              final XFile? image = await picker.pickImage(
                source: source,
                imageQuality: 85,
                maxWidth: 800,
                maxHeight: 800,
              );
              if (image != null) {
                setDialogState(() {
                  localImagePath = image.path;
                });
              }
            } catch (e) {
              debugPrint('Error picking image: $e');
            }
          }

          return AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 2),
            ),
            title: Text(
              'Edit Skincare Product',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade50,
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: localImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.file(
                                  File(localImagePath!),
                                  fit: BoxFit.cover,
                                  width: 65,
                                  height: 65,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: buildProductImage(item.imageUrl),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Image',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textColor,
                                    side: BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () =>
                                      pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt, size: 12),
                                  label: const Text(
                                    'Camera',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textColor,
                                    side: BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () =>
                                      pickImage(ImageSource.gallery),
                                  icon: const Icon(
                                    Icons.photo_library,
                                    size: 12,
                                  ),
                                  label: const Text(
                                    'Gallery',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                  TextField(
                    controller: brandController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Brand',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: dialogBg,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                    items: () {
                      final list = vm.categories.map((c) => c.name).toList();
                      if (!list.contains(selectedCategory)) {
                        list.add(selectedCategory);
                      }
                      if (list.isEmpty) {
                        list.add('Serum');
                      }
                      return list.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }).toList();
                    }(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCategory = val);
                      }
                    },
                  ),
                  TextField(
                    controller: priceController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Price (USD)',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextField(
                    controller: usesController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Estimated Uses',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: remainingUsesController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Remaining Uses',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: sizeController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Product Size (e.g. 50 ml)',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                  TextField(
                    controller: ingredientsController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Ingredients (comma separated)',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
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
                  if (nameController.text.isNotEmpty) {
                    final matchingCategory = vm.categories.firstWhere(
                      (c) => c.name.toLowerCase() == selectedCategory.toLowerCase(),
                      orElse: () => SkincareCategory(id: '', name: selectedCategory, color: item.indicatorColor),
                    );
                    String hexColor = matchingCategory.color;

                    final ingList = ingredientsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    vm.editProduct(
                      itemId: item.id,
                      name: nameController.text,
                      brand: brandController.text,
                      category: selectedCategory,
                      price:
                          double.tryParse(priceController.text) ?? item.price,
                      estimatedUses:
                          int.tryParse(usesController.text) ??
                          item.estimatedUses,
                      remainingUses:
                          int.tryParse(remainingUsesController.text) ??
                          item.remainingUses,
                      colorHex: hexColor,
                      currentImageUrl: item.imageUrl,
                      localImagePath: localImagePath,
                      userId: userId,
                      ingredients: ingList,
                      productSize: sizeController.text.trim().isEmpty
                          ? null
                          : sizeController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
