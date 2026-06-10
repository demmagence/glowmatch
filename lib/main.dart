import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/viewmodels/auth_viewmodel.dart';
import 'features/home/routine_viewmodel.dart';
import 'features/shelf/shelf_viewmodel.dart';
import 'features/budget/budget_viewmodel.dart';
import 'features/scanner/scanner_viewmodel.dart';
import 'features/journal/journal_viewmodel.dart';
import 'features/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SupabaseService. By default using placeholder URLs triggers clean offline-mock fallback.
  final supabaseService = SupabaseService();
  await supabaseService.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const GlowMatchApp());
}

class GlowMatchApp extends StatelessWidget {
  const GlowMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => RoutineViewModel()),
        ChangeNotifierProvider(create: (_) => ShelfViewModel()),
        ChangeNotifierProvider(create: (_) => BudgetViewModel()),
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => JournalViewModel()),
      ],
      child: MaterialApp(
        title: 'GlowMatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Outfit',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pinkAccent,
            primary: Colors.black,
            secondary: Colors.pinkAccent,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            centerTitle: true,
          ),
        ),
        home: const MainLayout(),
      ),
    );
  }
}
