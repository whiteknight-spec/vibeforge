import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      emoji: '✅',
      title: 'Track Your Habits',
      titleTa: 'உங்கள் பழக்கங்களைக் கண்காணியுங்கள்',
      description: 'Build consistency in diet, exercise, coding, and lifestyle with a beautiful daily checklist.',
      descriptionTa: 'அழகான தினசரி பட்டியலுடன் உணவு, உடற்பயிற்சி, கோடிங் மற்றும் வாழ்க்கை முறையில் நிலைத்தன்மையை உருவாக்குங்கள்.',
      color: AppColors.primary,
    ),
    _OnboardingData(
      emoji: '📊',
      title: 'See Your Progress',
      titleTa: 'உங்கள் முன்னேற்றத்தைப் பாருங்கள்',
      description: 'Weekly selfies, charts, and streaks to visualize your transformation journey.',
      descriptionTa: 'வாராந்திர செல்ஃபிகள், விளக்கப்படங்கள் மற்றும் தொடர்கள் மூலம் உங்கள் மாற்ற பயணத்தைக் காட்சிப்படுத்துங்கள்.',
      color: AppColors.secondary,
    ),
    _OnboardingData(
      emoji: '🤖',
      title: 'AI-Powered Coaching',
      titleTa: 'AI இயக்கப்படும் பயிற்சி',
      description: 'Get personalized workout, diet, and motivation suggestions powered by AI.',
      descriptionTa: 'AI மூலம் இயக்கப்படும் தனிப்பயனாக்கப்பட்ட பயிற்சி, உணவு மற்றும் ஊக்க பரிந்துரைகளைப் பெறுங்கள்.',
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Skip'),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: page.color.withAlpha(26),
                            boxShadow: [BoxShadow(color: page.color.withAlpha(51), blurRadius: 30)],
                          ),
                          child: Center(child: Text(page.emoji, style: const TextStyle(fontSize: 56))),
                        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.7, 0.7)),
                        const SizedBox(height: 40),
                        Text(page.title, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center)
                            .animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(page.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryDark, height: 1.6,
                        ), textAlign: TextAlign.center)
                            .animate().fadeIn(duration: 500.ms, delay: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _currentPage ? _pages[i].color : AppColors.textTertiaryDark,
                        boxShadow: i == _currentPage
                            ? [BoxShadow(color: _pages[i].color.withAlpha(102), blurRadius: 8)]
                            : null,
                      ),
                    )),
                  ),
                  const Spacer(),
                  // Next / Get Started
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                      } else {
                        context.go('/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    child: Text(_currentPage < _pages.length - 1 ? 'Next' : 'Get Started'),
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

class _OnboardingData {
  final String emoji, title, titleTa, description, descriptionTa;
  final Color color;
  const _OnboardingData({required this.emoji, required this.title, required this.titleTa, required this.description, required this.descriptionTa, required this.color});
}
