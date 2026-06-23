import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/viewmodels/currency_viewmodel.dart';
import '../shelf_viewmodel.dart';

void showAddProductDialog(
  BuildContext context,
  String userId,
  ShelfViewModel vm, {
  List<String>? preFilledIngredients,
}) {
  final currencyVm = Provider.of<CurrencyViewModel>(context, listen: false);
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final sizeController = TextEditingController();
  final ingredientsController = TextEditingController(
    text: preFilledIngredients != null ? preFilledIngredients.join(', ') : '',
  );
  String selectedCategory = vm.categories.isNotEmpty ? vm.categories.first.name : 'Serum';
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
              'Add Skincare Product',
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
                            : const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 28,
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
                      hintText: 'e.g. Moisture Surge Intense',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
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
                      hintText: 'e.g. Clinique',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
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
                      hintText: 'Select a category',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
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
                    items: vm.categories.isEmpty
                        ? [
                            DropdownMenuItem(
                              value: 'Serum',
                              child: Text(
                                'Serum',
                                style: TextStyle(color: textColor),
                              ),
                            )
                          ]
                        : vm.categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.name,
                              child: Text(
                                cat.name,
                                style: TextStyle(color: textColor),
                              ),
                            );
                          }).toList(),
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
                      labelText: 'Price (${currencyVm.selectedCurrency})',
                      hintText: 'e.g. 150000',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
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
                    controller: sizeController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Product Size',
                      hintText: 'e.g. 30ml, 50g',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
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
                      labelText: 'Ingredients',
                      hintText: 'e.g. Niacinamide, Hyaluronic Acid, Ceramide',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
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
                      orElse: () => SkincareCategory(id: '', name: selectedCategory, color: '0xFFE040FB'),
                    );
                    String hexColor = matchingCategory.color;

                    final ingList = ingredientsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    final priceInput = double.tryParse(priceController.text);
                    final priceInIDR = priceInput != null
                        ? currencyVm.convertToIDR(priceInput)
                        : currencyVm.convertUSDToIDR(20.0);

                    vm.addProduct(
                      userId: userId,
                      name: nameController.text,
                      brand: brandController.text,
                      category: selectedCategory,
                      price: priceInIDR,
                      estimatedUses: 50,
                      colorHex: hexColor,
                      localImagePath: localImagePath,
                      ingredients: ingList,
                      productSize: sizeController.text.trim().isEmpty
                          ? null
                          : sizeController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Add Product',
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
