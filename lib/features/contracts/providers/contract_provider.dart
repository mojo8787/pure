import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/subscription.dart';
import 'package:pureflow/core/services/auth_service.dart';
import 'package:pureflow/core/services/subscription_service.dart';

part 'contract_provider.g.dart';

@riverpod
class ContractProvider extends _$ContractProvider {
  @override
  Future<Contract?> build() async {
    return null; // Initial state is null
  }

  /// Create a draft subscription
  Future<Subscription> createDraftSubscription({
    required String plan,
    required double priceMonthly,
  }) async {
    // Get the current user
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    state = const AsyncLoading();
    
    try {
      // Create a draft subscription
      final subscription = await ref
          .read(subscriptionServiceProvider)
          .createDraftSubscription(
            customerId: user.id,
            plan: plan,
            priceMonthly: priceMonthly,
          );
      
      return subscription;
    } catch (e, st) {
      state = AsyncError(e, st);
      throw Exception('Failed to create draft subscription: ${e.toString()}');
    }
  }

  /// Create a contract for the user
  Future<Contract> createContract({required String fileUrl}) async {
    // Get the current user
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    state = const AsyncLoading();
    
    try {
      // Create a contract
      final contract = await ref
          .read(subscriptionServiceProvider)
          .createContract(
            customerId: user.id,
            fileUrl: fileUrl,
          );
      
      state = AsyncData(contract);
      return contract;
    } catch (e, st) {
      state = AsyncError(e, st);
      throw Exception('Failed to create contract: ${e.toString()}');
    }
  }

  /// Mark contract as signed
  Future<void> signContract(String contractId) async {
    state = const AsyncLoading();
    
    try {
      // Update contract status to signed
      await ref
          .read(subscriptionServiceProvider)
          .updateContractStatus(
            id: contractId,
            status: ContractStatus.signed,
          );
      
      // Reload the contract
      final contract = await ref
          .read(subscriptionServiceProvider)
          .getContract(contractId);
      
      state = AsyncData(contract);
    } catch (e, st) {
      state = AsyncError(e, st);
      throw Exception('Failed to sign contract: ${e.toString()}');
    }
  }
}

@riverpod
class ActiveSubscription extends _$ActiveSubscription {
  @override
  Future<Subscription?> build() async {
    // Get the current user
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    if (user == null) return null;

    try {
      // Get customer's subscriptions
      final subscriptions = await ref
          .read(subscriptionServiceProvider)
          .getCustomerSubscriptions(user.id);

      // If no subscription, return null
      if (subscriptions.isEmpty) return null;

      // Use the first active subscription (or the first one if none are active)
      final activeSubscriptions = subscriptions
          .where((s) => s.status == SubscriptionStatus.active)
          .toList();
      
      return activeSubscriptions.isNotEmpty
          ? activeSubscriptions.first
          : subscriptions.first;
    } catch (e) {
      throw Exception('Failed to get active subscription: ${e.toString()}');
    }
  }
} 