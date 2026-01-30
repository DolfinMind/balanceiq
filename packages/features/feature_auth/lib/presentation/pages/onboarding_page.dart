import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get_it/get_it.dart';
import 'package:feature_auth/constants/auth_strings.dart';
import 'package:dolfin_core/constants/core_strings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.hub,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    GetIt.I<CoreStrings>().appName,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  _buildSlide(
                    icon: Icons.auto_awesome,
                    title: GetIt.I<AuthStrings>().onboarding.slide1Title,
                    description:
                        GetIt.I<AuthStrings>().onboarding.slide1Description,
                  ),
                  _buildSlide(
                    icon: Icons.account_tree,
                    title: GetIt.I<AuthStrings>().onboarding.slide2Title,
                    description:
                        GetIt.I<AuthStrings>().onboarding.slide2Description,
                  ),
                  _buildSlide(
                    icon: Icons.smart_toy,
                    title: GetIt.I<AuthStrings>().onboarding.slide3Title,
                    description:
                        GetIt.I<AuthStrings>().onboarding.slide3Description,
                  ),
                  _buildSlide(
                    icon: Icons.dashboard,
                    title: GetIt.I<AuthStrings>().onboarding.slide4Title,
                    description:
                        GetIt.I<AuthStrings>().onboarding.slide4Description,
                    isLast: true,
                  ),
                ],
              ),
            ),
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 4,
                effect: WormEffect(
                  dotColor: colorScheme.onSurface.withValues(alpha: 0.2),
                  activeDotColor: colorScheme.primary,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 12,
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _navigateToSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        GetIt.I<AuthStrings>().onboarding.getStarted,
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        GetIt.I<AuthStrings>().onboarding.loginButton,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
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

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isLast
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 24,
                          left: 40,
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          top: 64,
                          right: 24,
                          child: Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 56,
                          child: Icon(
                            Icons.school,
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 80,
                    ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
