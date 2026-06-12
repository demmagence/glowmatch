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
import 'features/splash/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
              textTheme: GoogleFonts.outfitTextTheme(),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.pinkAccent,
                primary: Colors.black,
                secondary: Colors.pinkAccent,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
                titleTextStyle: GoogleFonts.outfit(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                centerTitle: true,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
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
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: const Color(0xFF121212),
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                centerTitle: true,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
