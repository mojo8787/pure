import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:pureflow/core/services/auth_service.dart';
import 'package:pureflow/shared/constants/colors.dart';
import 'package:pureflow/features/onboarding/providers/onboarding_provider.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    
    // Navigate to the appropriate screen after checking auth status
    useEffect(() {
      Future.delayed(const Duration(seconds: 2), () {
        if (user != null) {
          // User is authenticated, navigate based on role
          switch (user.role) {
            case UserRole.customer:
              context.go(Routes.dashboard);
              break;
            case UserRole.technician:
              context.go(Routes.techSchedule);
              break;
            case UserRole.admin:
              context.go(Routes.adminDashboard);
              break;
          }
        } else {
          // Check if onboarding has been seen
          final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);
          if (hasSeenOnboarding) {
            context.go(Routes.auth);
          } else {
            context.go(Routes.onboarding);
          }
        }
      });
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with actual Lottie file once available
              Lottie.asset(
                'assets/lottie/water_drop.json',
                width: 128,
                height: 128,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'PureFlow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 