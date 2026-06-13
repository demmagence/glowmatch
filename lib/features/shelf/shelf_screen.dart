import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'shelf_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/models/models.dart';
import '../../core/widgets/glowmatch_header.dart';
import '../../core/widgets/neobrutalist_card.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/constants.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonCard() {
    return NeobrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade50,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 10,
                  color: Colors.grey.shade100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.dry_cleaning_outlined, size: 48, color: Colors.grey);
    }
    final isLocal = !imageUrl.startsWith('http') && !imageUrl.startsWith('assets');
    final isAsset = imageUrl.startsWith('assets');
    if (isLocal) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.dry_cleaning_outlined, size: 48, color: Colors.grey);
        },
      );
    } else if (isAsset) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.dry_cleaning_outlined, size: 48, color: Colors.grey);
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.dry_cleaning_outlined, size: 48, color: Colors.grey);
        },
      );
    }
  }

  Widget _buildSearchBar(ShelfViewModel shelfVm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => shelfVm.setSearchQuery(val),
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search products by name or brand...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          suffixIcon: shelfVm.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    shelfVm.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shelfVm = Provider.of<ShelfViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => shelfVm.fetchShelf(authVm.userId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: GlowMatch.
              const GlowMatchHeader(),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(shelfVm),
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

              // Products Grid or loading/error
              if (shelfVm.errorMessage != null)
                ErrorStateWidget(
                  message: shelfVm.errorMessage!,
                  onRetry: () => shelfVm.fetchShelf(authVm.userId),
                )
              else if (shelfVm.isLoading)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) => _buildSkeletonCard(),
                )
              else
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
                      return NeobrutalistCard(
                        shadowColor: Colors.grey,
                        onTap: () => _showAddProductDialog(context, authVm.userId, shelfVm),
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
                      );
                    }

                    final item = shelfVm.filteredItems[index];
                    return _buildNeobrutalistProductCard(context, item, shelfVm);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeobrutalistProductCard(BuildContext context, ShelfItem item, ShelfViewModel shelfVm) {
    final colorHex = item.indicatorColor;
    final dotColor = Color(int.parse(colorHex));
    final int estimatedUses = item.estimatedUses;
    final int remainingUses = item.remainingUses;
    final double price = item.price;
    final bool isEmpty = remainingUses <= 0;
    final double progress = estimatedUses > 0 ? (remainingUses / estimatedUses).clamp(0.0, 1.0) : 0.0;

    return NeobrutalistCard(
      onTap: () => _showProductDetailsBottomSheet(context, item, shelfVm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Packaging Image
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
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
                    child: _buildProductImage(item.imageUrl),
                  ),
                ),
                // Price Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '\$${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Delete Button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _showDeleteConfirmation(context, item, shelfVm),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.black),
                    ),
                  ),
                ),
                // Finished Overlay
                if (isEmpty)
                  Container(
                    color: Colors.white.withValues(alpha: 0.65),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.black, width: 1.5),
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
          // Product Info Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
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
                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    color: dotColor,
                    backgroundColor: Colors.grey.shade200,
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
                        color: isEmpty ? Colors.red : Colors.grey.shade600,
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
                              backgroundColor: Colors.black,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Text(
                              'USE',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
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

  void _showProductDetailsBottomSheet(BuildContext context, ShelfItem item, ShelfViewModel shelfVm) {
    final colorHex = item.indicatorColor;
    final dotColor = Color(int.parse(colorHex));
    final int estimatedUses = item.estimatedUses;
    final int remainingUses = item.remainingUses;
    final double price = item.price;
    final double costPerApply = estimatedUses > 0 ? price / estimatedUses : 0.0;
    final List<String> ingredients = item.ingredients;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
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
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: _buildProductImage(item.imageUrl),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.brand,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  _buildDetailMetric('PRICE', '\$${price.toStringAsFixed(2)}'),
                  _buildDetailMetric('USES REMAINING', '$remainingUses / $estimatedUses'),
                  _buildDetailMetric('COST PER USE', '\$${costPerApply.toStringAsFixed(2)}'),
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
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ingredients.map((ing) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300, width: 0.8),
                          ),
                          child: Text(
                            ing,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
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
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditProductDialog(context, item, shelfVm);
                      },
                      child: const Text('EDIT PRODUCT', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        _showDeleteConfirmation(context, item, shelfVm);
                      },
                      child: const Text('DELETE PRODUCT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: remainingUses > 0
                      ? () {
                          shelfVm.useProduct(item.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Used 1 apply of ${item.name}!'),
                              backgroundColor: Colors.black,
                            ),
                          );
                        }
                      : null,
                  child: const Text('USE PRODUCT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailMetric(String label, String value) {
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, ShelfItem item, ShelfViewModel shelfVm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete ${item.name} from your shelf?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                shelfVm.deleteProduct(item.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${item.name}'),
                    backgroundColor: Colors.black,
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

  void _showFilterDialog(BuildContext context, ShelfViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        final categories = ['All', ...SkincareCategory.values.map((e) => e.displayName)];
        return SimpleDialog(
          title: const Text('Filter by Category', style: TextStyle(fontWeight: FontWeight.bold)),
          children: categories.map((category) {
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
    final ingredientsController = TextEditingController();
    String selectedCategory = 'Serum';
    String? localImagePath;

    final ImagePicker picker = ImagePicker();

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Add Skincare Product', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker Widget
                    Row(
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.black, width: 1.5),
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
                              : const Icon(Icons.image, color: Colors.grey, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Product Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(color: Colors.black, width: 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    onPressed: () => pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt, size: 12),
                                    label: const Text('Camera', style: TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(color: Colors.black, width: 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    onPressed: () => pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library, size: 12),
                                    label: const Text('Gallery', style: TextStyle(fontSize: 10)),
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
                      decoration: const InputDecoration(labelText: 'Product Name (e.g. GlowBomb)'),
                    ),
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Brand (e.g. Skin1004)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory, // ignore: deprecated_member_use
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: SkincareCategory.values.map((e) => e.displayName).map((cat) {
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
                    TextField(
                      controller: ingredientsController,
                      decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'),
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
                      String hexColor = AppConstants.categoryColors[selectedCategory] ?? '0xFFE040FB';

                      final ingList = ingredientsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      vm.addProduct(
                        userId: userId,
                        name: nameController.text,
                        brand: brandController.text,
                        category: selectedCategory,
                        price: double.tryParse(priceController.text) ?? 20.0,
                        estimatedUses: int.tryParse(usesController.text) ?? 50,
                        colorHex: hexColor,
                        localImagePath: localImagePath,
                        ingredients: ingList,
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

  void _showEditProductDialog(BuildContext context, ShelfItem item, ShelfViewModel vm) {
    final nameController = TextEditingController(text: item.name);
    final brandController = TextEditingController(text: item.brand);
    final priceController = TextEditingController(text: item.price.toString());
    final usesController = TextEditingController(text: item.estimatedUses.toString());
    final remainingUsesController = TextEditingController(text: item.remainingUses.toString());
    final ingredientsController = TextEditingController(text: item.ingredients.join(', '));
    String selectedCategory = item.category;
    String? localImagePath;

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final userId = Provider.of<AuthViewModel>(context, listen: false).userId;

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Edit Skincare Product', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker Widget
                    Row(
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.black, width: 1.5),
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
                                  child: _buildProductImage(item.imageUrl),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Product Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(color: Colors.black, width: 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    onPressed: () => pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt, size: 12),
                                    label: const Text('Camera', style: TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(color: Colors.black, width: 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    onPressed: () => pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library, size: 12),
                                    label: const Text('Gallery', style: TextStyle(fontSize: 10)),
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
                      decoration: const InputDecoration(labelText: 'Product Name'),
                    ),
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory, // ignore: deprecated_member_use
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: SkincareCategory.values.map((e) => e.displayName).map((cat) {
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
                    TextField(
                      controller: remainingUsesController,
                      decoration: const InputDecoration(labelText: 'Remaining Uses'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: ingredientsController,
                      decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'),
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
                      String hexColor = item.indicatorColor;
                      if (selectedCategory != item.category) {
                        hexColor = AppConstants.categoryColors[selectedCategory] ?? '0xFFE040FB';
                      }

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
                        price: double.tryParse(priceController.text) ?? item.price,
                        estimatedUses: int.tryParse(usesController.text) ?? item.estimatedUses,
                        remainingUses: int.tryParse(remainingUsesController.text) ?? item.remainingUses,
                        colorHex: hexColor,
                        currentImageUrl: item.imageUrl,
                        localImagePath: localImagePath,
                        userId: userId,
                        ingredients: ingList,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
