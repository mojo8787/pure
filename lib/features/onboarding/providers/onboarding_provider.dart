import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_provider.g.dart';

const String _hasSeenOnboardingKey = 'has_seen_onboarding';

/// Provider to check if user has seen the onboarding
@riverpod
Future<bool> hasSeenOnboarding(HasSeenOnboardingRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_hasSeenOnboardingKey) ?? false;
}

/// Provider to set onboarding as seen
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  FutureOr<void> build() {
    // Nothing to initialize
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// Reset onboarding status (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
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