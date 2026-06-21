import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_layout.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const TextSpan(
                text: '.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
