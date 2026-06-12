import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/viewmodels/auth_viewmodel.dart';
import 'core/viewmodels/theme_viewmodel.dart';
import 'features/home/routine_viewmodel.dart';
import 'features/shelf/shelf_viewmodel.dart';
import 'features/budget/budget_viewmodel.dart';
import 'features/scanner/scanner_viewmodel.dart';
import 'features/journal/journal_viewmodel.dart';
import 'features/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'YOUR_SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR_SUPABASE_ANON_KEY');

  final supabaseService = SupabaseService();
  await supabaseService.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const GlowMatchApp());
}

class GlowMatchApp extends StatelessWidget {
  const GlowMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => RoutineViewModel()),
        ChangeNotifierProvider(create: (_) => ShelfViewModel()),
        ChangeNotifierProxyProvider<ShelfViewModel, BudgetViewModel>(
          create: (_) => BudgetViewModel(),
          update: (_, shelfVm, budgetVm) {
            if (budgetVm != null) {
              budgetVm.setLoading(shelfVm.isLoading);
              budgetVm.updateFromShelf(shelfVm.shelfItems);
            }
            return budgetVm!;
          },
        ),
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => JournalViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, child) {
          return MaterialApp(
            title: 'GlowMatch',
            debugShowCheckedModeBanner: false,
            themeMode: themeVm.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Outfit',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.pinkAccent,
                primary: Colors.black,
                secondary: Colors.pinkAccent,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(color: Colors.black, fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.bold),
                centerTitle: true,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Outfit',
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: Colors.pinkAccent,
                primary: Colors.white,
                secondary: Colors.pinkAccent,
                surface: const Color(0xFF121212),
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Color(0xFF121212),
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.bold),
                centerTitle: true,
              ),
            ),
            home: const MainLayout(),
          );
        },
      ),
    );
  }
}
