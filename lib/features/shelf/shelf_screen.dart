import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shelf_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shelfVm = Provider.of<ShelfViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: GlowMatch.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'GlowMatch',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: Colors.red, fontSize: 32),
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title and FILTER Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Shelf',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => _showFilterDialog(context, shelfVm),
                  child: const Text(
                    'FILTER',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Products Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shelfVm.filteredItems.length + 1, // +1 for the Add New Card
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                if (index == shelfVm.filteredItems.length) {
                  // Add Skincare Card
                  return GestureDetector(
                    onTap: () => _showAddProductDialog(context, authVm.userId, shelfVm),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.2),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 0,
                            offset: Offset(4, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, size: 48, color: Colors.black),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'tekan untuk tambah skincare baru',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final item = shelfVm.filteredItems[index];
                return _buildNeobrutalistProductCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeobrutalistProductCard(Map<String, dynamic> item) {
    // Determine category dot color
    final colorHex = item['indicator_color'] ?? '0xFFE040FB';
    final dotColor = Color(int.parse(colorHex));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 0,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Packaging Image Placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
                child: Image.network(
                  item['image_url'] ?? 'https://placehold.co/150',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.dry_cleaning_outlined, size: 48, color: Colors.grey);
                  },
                ),
              ),
            ),
          ),
          // Product Info Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item['category'] ?? 'Serum',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
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

  void _showFilterDialog(BuildContext context, ShelfViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Filter by Category', style: TextStyle(fontWeight: FontWeight.bold)),
          children: ['All', 'Serum', 'Moisturizer', 'Cleanser', 'Sunscreen'].map((category) {
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
                    fontWeight: vm.selectedCategoryFilter == category ? FontWeight.bold : FontWeight.normal,
                    color: vm.selectedCategoryFilter == category ? Colors.pink : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context, String userId, ShelfViewModel vm) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    final usesController = TextEditingController();
    String selectedCategory = 'Serum';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Add Skincare Product', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Product Name (e.g. GlowBomb)'),
                    ),
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Brand (e.g. Skin1004)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory, // ignore: deprecated_member_use
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Serum', 'Moisturizer', 'Cleanser', 'Sunscreen'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCategory = val);
                      },
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price (USD)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(
                      controller: usesController,
                      decoration: const InputDecoration(labelText: 'Estimated Uses'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      String hexColor = '0xFFE040FB'; // default purple
                      if (selectedCategory == 'Sunscreen') {
                        hexColor = '0xFF64DD17'; // green
                      } else if (selectedCategory == 'Moisturizer') {
                        hexColor = '0xFFD50000'; // red
                      }

                      vm.addProduct(
                        userId: userId,
                        name: nameController.text,
                        brand: brandController.text,
                        category: selectedCategory,
                        price: double.tryParse(priceController.text) ?? 20.0,
                        estimatedUses: int.tryParse(usesController.text) ?? 50,
                        colorHex: hexColor,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Product', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
