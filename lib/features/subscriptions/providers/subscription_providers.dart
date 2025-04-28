import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/subscription.dart';
import 'package:pureflow/core/services/subscription_service.dart';

part 'subscription_providers.g.dart';

// Temporary fake user ID for testing - using a valid UUID format
const String testUserId = '00000000-0000-0000-0000-000000000000';

@riverpod
Future<List<Subscription>> userSubscriptions(UserSubscriptionsRef ref) async {
  // Using a test user ID instead of authentication
  return ref.watch(subscriptionServiceProvider).getUserSubscriptions(testUserId);
}

@riverpod
Future<Subscription> subscription(SubscriptionRef ref, String subscriptionId) {
  return ref.watch(subscriptionServiceProvider).getSubscription(subscriptionId);
}

@riverpod
Future<List<Map<String, dynamic>>> subscriptionPlans(SubscriptionPlansRef ref) {
  return ref.watch(subscriptionServiceProvider).getSubscriptionPlans();
}

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  FutureOr<void> build() {
    // Nothing to initialize
  }
  
  Future<Subscription> createSubscription({
    required String plan,
    required double priceMonthly,
  }) async {
    state = const AsyncLoading();
    
    try {
      // Using test user ID instead of authentication
      final subscription = await ref.read(subscriptionServiceProvider).createSubscription(
            customerId: testUserId,
            plan: plan,
            priceMonthly: priceMonthly,
          );
      
      // Invalidate the user subscriptions to refresh the list
      ref.invalidate(userSubscriptionsProvider);
      
      state = const AsyncData(null);
      return subscription;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  
  Future<Subscription> cancelSubscription(String subscriptionId) async {
    state = const AsyncLoading();
    
    try {
      final subscription = await ref.read(subscriptionServiceProvider)
          .cancelSubscription(subscriptionId);
      
      // Invalidate the user subscriptions to refresh the list
      ref.invalidate(userSubscriptionsProvider);
      ref.invalidate(subscriptionProvider(subscriptionId));
      
      state = const AsyncData(null);
      return subscription;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  
  Future<Subscription> updateSubscriptionStatus({
    required String subscriptionId,
    required SubscriptionStatus status,
  }) async {
    state = const AsyncLoading();
    
    try {
      final subscription = await ref.read(subscriptionServiceProvider)
          .updateSubscriptionStatus(
            subscriptionId: subscriptionId,
            status: status,
          );
      
      // Invalidate the providers to refresh the data
      ref.invalidate(userSubscriptionsProvider);
      ref.invalidate(subscriptionProvider(subscriptionId));
      
      state = const AsyncData(null);
      return subscription;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
} 