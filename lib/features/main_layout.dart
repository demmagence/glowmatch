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

  final List<Widget> _screens = [
    const HomeScreen(),
    const BudgetScreen(),
    const SizedBox.shrink(), // Placeholder for Scanner FAB
    const JournalScreen(),
    const ShelfScreen(),
  ];

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex == 2 ? 0 : _currentIndex, // Default fallback if 2 selected directly
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: Colors.white,
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterScanButton() {
    return GestureDetector(
      onTap: () {
        // Direct modal/navigation to OCR scanning camera screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ScannerScreen(),
          ),
        );
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.filter_center_focus_outlined, // Viewfinder scan icon
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
