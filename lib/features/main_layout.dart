import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'budget/budget_screen.dart';
import 'journal/journal_screen.dart';
import 'shelf/shelf_screen.dart';
import 'scanner/scanner_screen.dart';
import '../core/viewmodels/auth_viewmodel.dart';
import 'home/routine_viewmodel.dart';
import 'shelf/shelf_viewmodel.dart';
import 'journal/journal_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  List<String>? _preFilledIngredients;

  @override
  void initState() {
    super.initState();
    // Pre-fetch data for all view models on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      final userId = auth.userId;
      Provider.of<RoutineViewModel>(context, listen: false).init(userId);
      Provider.of<ShelfViewModel>(context, listen: false).fetchShelf(userId);
      Provider.of<JournalViewModel>(context, listen: false).fetchJournal(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final navBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex == 2 ? 0 : _currentIndex, // Default fallback if 2 selected directly
          children: [
            const HomeScreen(),
            const BudgetScreen(),
            const SizedBox.shrink(), // Placeholder for Scanner FAB
            const JournalScreen(),
            ShelfScreen(
              initialIngredientsToPreFill: _preFilledIngredients,
              onClearPreFill: () {
                setState(() {
                  _preFilledIngredients = null;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: navBarBg,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.grid_view_rounded, 'Home', 0),
              _buildNavItem(Icons.account_balance_wallet_outlined, 'Budget', 1),
              _buildCenterScanButton(),
              _buildNavItem(Icons.assignment_outlined, 'Journal', 3),
              _buildNavItem(Icons.inventory_2_outlined, 'Shelf', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final badgeBorder = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Check if we need to show low stock badge on the Shelf tab (index 4)
    bool showLowStockBadge = false;
    if (index == 4) {
      final shelfVm = Provider.of<ShelfViewModel>(context);
      showLowStockBadge = shelfVm.shelfItems.any((item) => item.remainingUses < 5);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        final auth = Provider.of<AuthViewModel>(context, listen: false);
        final userId = auth.userId;
        if (index == 0) {
          Provider.of<RoutineViewModel>(context, listen: false).init(userId);
        } else if (index == 3) {
          Provider.of<JournalViewModel>(context, listen: false).fetchJournal(userId);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 26,
                ),
              ),
              if (showLowStockBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: badgeBorder, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 16 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterScanButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark ? Colors.white : Colors.black;
    final btnFg = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () async {
        // Direct modal/navigation to OCR scanning camera screen
        final List<String>? ingredients = await Navigator.of(context).push<List<String>>(
          MaterialPageRoute(
            builder: (context) => const ScannerScreen(),
          ),
        );
        if (ingredients != null) {
          setState(() {
            _preFilledIngredients = ingredients;
            _currentIndex = 4; // Shelf Screen tab
          });
        }
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: btnBg,
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white54 : Colors.transparent, width: 1),
        ),
        child: Icon(
          Icons.filter_center_focus_outlined, // Viewfinder scan icon
          color: btnFg,
          size: 28,
        ),
      ),
    );
  }
}
