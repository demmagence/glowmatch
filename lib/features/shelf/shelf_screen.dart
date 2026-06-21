import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shelf_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/widgets/glowmatch_header.dart';
import '../../core/widgets/neobrutalist_card.dart';
import '../../core/widgets/error_state_widget.dart';
import 'widgets/skeleton_card.dart';
import 'widgets/product_card.dart';
import 'widgets/filter_dialog.dart';
import 'widgets/add_product_dialog.dart';
import 'widgets/manage_categories_screen.dart';

class ShelfScreen extends StatefulWidget {
  final List<String>? initialIngredientsToPreFill;
  final VoidCallback? onClearPreFill;
  const ShelfScreen({
    super.key,
    this.initialIngredientsToPreFill,
    this.onClearPreFill,
  });

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.initialIngredientsToPreFill != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAddProductDialog(
          context,
          Provider.of<AuthViewModel>(context, listen: false).userId,
          Provider.of<ShelfViewModel>(context, listen: false),
          preFilledIngredients: widget.initialIngredientsToPreFill,
        );
        widget.onClearPreFill?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ShelfScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIngredientsToPreFill != null &&
        widget.initialIngredientsToPreFill !=
            oldWidget.initialIngredientsToPreFill) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAddProductDialog(
          context,
          Provider.of<AuthViewModel>(context, listen: false).userId,
          Provider.of<ShelfViewModel>(context, listen: false),
          preFilledIngredients: widget.initialIngredientsToPreFill,
        );
        widget.onClearPreFill?.call();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(BuildContext context, ShelfViewModel shelfVm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark ? Colors.white : Colors.black;
    final shadow = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(color: shadow, offset: const Offset(4, 4), blurRadius: 0),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => shelfVm.setSearchQuery(val),
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        decoration: InputDecoration(
          hintText: 'Search products by name or brand...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search, color: iconColor),
          suffixIcon: shelfVm.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: iconColor),
                  onPressed: () {
                    _searchController.clear();
                    shelfVm.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shelfVm = Provider.of<ShelfViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => shelfVm.fetchShelf(authVm.userId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlowMatchHeader(),
              const SizedBox(height: 24),

              _buildSearchBar(context, shelfVm),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Shelf',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(color: textColor, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCategoriesScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.category, size: 16),
                        label: const Text(
                          'CATEGORIES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(color: textColor, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () => showFilterDialog(context, shelfVm),
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
                ],
              ),
              const SizedBox(height: 24),

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
                  itemBuilder: (context, index) => SkeletonCard(),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: shelfVm.filteredItems.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    if (index == shelfVm.filteredItems.length) {
                      return NeobrutalistCard(
                        shadowColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade300,
                        onTap: () => showAddProductDialog(
                          context,
                          authVm.userId,
                          shelfVm,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 48, color: textColor),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(
                                'tekan untuk tambah skincare baru',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final item = shelfVm.filteredItems[index];
                    return ProductCard(item: item, shelfVm: shelfVm);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
