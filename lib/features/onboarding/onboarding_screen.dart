import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Track Your Glow',
      'description': 'Log your AM & PM skincare routines and maintain a visual skin progress journal.',
      'icon': 'event_note',
    },
    {
      'title': 'Scan Ingredients',
      'description': 'Use AI to scan product ingredients via OCR and check their safety and compatibility.',
      'icon': 'center_focus_strong',
    },
    {
      'title': 'Smart Budget',
      'description': 'Keep track of your skincare spending and analyze cost-per-apply efficiency.',
      'icon': 'account_balance_wallet',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'event_note':
        return Icons.event_note;
      case 'center_focus_strong':
        return Icons.center_focus_strong;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.star;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Neo-brutalist Illustration Placeholder
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent.shade100,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconData(_onboardingData[index]['icon']!),
                            size: 100,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          _onboardingData[index]['title']!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _onboardingData[index]['description']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 12,
                        width: _currentPage == index ? 32 : 12,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.pinkAccent : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
