import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/sign_in_screen.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _getOnboardingData(AppLocalizations l10n) => [
    {
      'title': l10n.onboardingTitle1,
      'description': l10n.onboardingDesc1,
      'icon': 'event_note',
    },
    {
      'title': l10n.onboardingTitle2,
      'description': l10n.onboardingDesc2,
      'icon': 'center_focus_strong',
    },
    {
      'title': l10n.onboardingTitle3,
      'description': l10n.onboardingDesc3,
      'icon': 'account_balance_wallet',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
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
    final l10n = AppLocalizations.of(context)!;
    final onboardingData = _getOnboardingData(l10n);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black;
    final illusBg = isDark
        ? Colors.pink.shade900.withValues(alpha: 0.4)
        : Colors.pinkAccent.shade100;
    final dotInactive = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  l10n.skip,
                  style: TextStyle(
                    color: textColor,
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
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: illusBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                offset: const Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconData(onboardingData[index]['icon']!),
                            size: 100,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          onboardingData[index]['title']!,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          onboardingData[index]['description']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 12,
                        width: _currentPage == index ? 32 : 12,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.pinkAccent
                              : dotInactive,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _nextPage(onboardingData.length),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            offset: const Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1
                            ? l10n.getStarted
                            : l10n.next,
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
