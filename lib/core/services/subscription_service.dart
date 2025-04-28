import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pureflow/core/models/subscription.dart';

part 'subscription_service.g.dart';

class SubscriptionService {
  final SupabaseClient _client;

  SubscriptionService(this._client);

  /// Get all subscriptions for a user
  Future<List<Subscription>> getUserSubscriptions(String userId) async {
    final response = await _client
        .from('subscriptions')
        .select()
        .eq('customer_id', userId)
        .order('created_at', ascending: false);

    return response.map((data) => Subscription.fromJson(data)).toList();
  }

  /// Get a single subscription by ID
  Future<Subscription> getSubscription(String subscriptionId) async {
    final response = await _client
        .from('subscriptions')
        .select()
        .eq('id', subscriptionId)
        .single();

    return Subscription.fromJson(response);
  }

  /// Create a new subscription
  Future<Subscription> createSubscription({
    required String customerId,
    required String plan,
    required double priceMonthly,
  }) async {
    final response = await _client.from('subscriptions').insert({
      'customer_id': customerId,
      'plan': plan,
      'price_monthly': priceMonthly,
      'status': 'pending',
    }).select().single();

    return Subscription.fromJson(response);
  }

  /// Update a subscription's status
  Future<Subscription> updateSubscriptionStatus({
    required String subscriptionId,
    required SubscriptionStatus status,
  }) async {
    final statusStr = status.toString().split('.').last;
    final response = await _client
        .from('subscriptions')
        .update({'status': statusStr})
        .eq('id', subscriptionId)
        .select()
        .single();

    return Subscription.fromJson(response);
  }

  /// Cancel a subscription
  Future<Subscription> cancelSubscription(String subscriptionId) async {
    final now = DateTime.now().toIso8601String();
    final response = await _client
        .from('subscriptions')
        .update({
          'status': 'cancelled',
          'cancelled_at': now,
        })
        .eq('id', subscriptionId)
        .select()
        .single();

    return Subscription.fromJson(response);
  }

  /// Get all available subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    // In a real application, this might come from the database
    // For now, we'll return some hardcoded plans
    return [
      {
        'id': 'basic',
        'name': 'Basic',
        'description': 'Standard water filtration with quarterly maintenance',
        'price_monthly': 25.0,
        'features': [
          'Standard filtration system',
          'Quarterly filter changes',
          'Basic water quality tests',
        ],
      },
      {
        'id': 'premium',
        'name': 'Premium',
        'description': 'Enhanced filtration with bi-monthly maintenance',
        'price_monthly': 40.0,
        'features': [
          'Advanced filtration system',
          'Bi-monthly filter changes',
          'Comprehensive water quality tests',
          'Priority customer support',
        ],
      },
      {
        'id': 'ultimate',
        'name': 'Ultimate',
        'description': 'Premium filtration with monthly maintenance and monitoring',
        'price_monthly': 60.0,
        'features': [
          'Premium filtration system with UV',
          'Monthly filter changes',
          'Continuous water quality monitoring',
          'Priority customer support',
          'Annual system inspection',
        ],
      },
    ];
  }
}

@riverpod
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return SubscriptionService(Supabase.instance.client);
} 