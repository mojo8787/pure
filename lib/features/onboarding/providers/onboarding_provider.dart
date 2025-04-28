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
  Future<void> build() async {
    // Initial state is void
  }

  /// Mark onboarding as seen
  Future<void> setOnboardingAsSeen() async {
    state = const AsyncLoading();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenOnboardingKey, true);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
} 