import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

part 'onboarding_provider.g.dart';

const String _hasSeenOnboardingKey = 'has_seen_onboarding';

/// Provider to check if user has seen the onboarding
@Riverpod(keepAlive: true)
class HasSeenOnboarding extends _$HasSeenOnboarding {
  @override
  Future<bool> build() async {
    debugPrint('HasSeenOnboarding: Building provider');
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_hasSeenOnboardingKey) ?? false;
    debugPrint('HasSeenOnboarding: Value from storage: $hasSeen');
    return hasSeen;
  }

  Future<void> setOnboardingCompleted() async {
    debugPrint('HasSeenOnboarding: Setting onboarding as completed');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
    state = const AsyncData(true);
    debugPrint('HasSeenOnboarding: Onboarding marked as completed');
  }

  Future<void> reset() async {
    debugPrint('HasSeenOnboarding: Resetting onboarding status');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenOnboardingKey);
    state = const AsyncData(false);
    debugPrint('HasSeenOnboarding: Onboarding status reset');
  }
}

@riverpod
class OnboardingProgress extends _$OnboardingProgress {
  @override
  int build() {
    return 0; // Start at first screen
  }

  void next() {
    state = state + 1;
  }

  void previous() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void reset() {
    state = 0;
  }
} 