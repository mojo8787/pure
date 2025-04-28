import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:pureflow/features/onboarding/providers/onboarding_provider.dart';
import 'package:pureflow/shared/constants/colors.dart';
import 'package:pureflow/features/onboarding/presentation/widgets/onboarding_page.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    
    final onboardingPages = [
      const OnboardingPage(
        imagePath: 'assets/images/why_ro.webp',
        title: 'Pure Water, Healthier Life',
        description: 'Reverse Osmosis filtration removes 99% of contaminants, '
            'providing the cleanest water for you and your family.',
      ),
      const OnboardingPage(
        imagePath: 'assets/images/how_it_works.webp',
        title: 'Hassle-Free Experience',
        description: 'Subscribe monthly for professional installation, '
            'regular maintenance, and filter replacements — all included.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) => currentPage.value = index,
                children: onboardingPages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Page dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: currentPage.value == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: currentPage.value == index
                              ? AppColors.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (currentPage.value < onboardingPages.length - 1) {
                          // Go to next page
                          await pageController.animateToPage(
                            currentPage.value + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Mark onboarding as seen and go to auth screen
                          await ref
                              .read(onboardingNotifierProvider.notifier)
                              .setOnboardingAsSeen();
                          if (context.mounted) {
                            context.go(Routes.auth);
                          }
                        }
                      },
                      child: Text(
                        currentPage.value < onboardingPages.length - 1
                            ? 'Next'
                            : 'Get Started',
                      ),
                    ),
                  ),
                  if (currentPage.value < onboardingPages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        // Skip onboarding
                        await ref
                            .read(onboardingNotifierProvider.notifier)
                            .setOnboardingAsSeen();
                        if (context.mounted) {
                          context.go(Routes.auth);
                        }
                      },
                      child: const Text('Skip'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 