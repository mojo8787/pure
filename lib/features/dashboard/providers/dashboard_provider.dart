import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/appointment.dart';
import 'package:pureflow/core/models/invoice.dart';
import 'package:pureflow/core/models/subscription.dart';
import 'package:pureflow/core/models/user.dart';
import 'package:pureflow/core/services/appointment_service.dart';
import 'package:pureflow/core/services/auth_service.dart';
import 'package:pureflow/core/services/invoice_service.dart';
import 'package:pureflow/core/services/subscription_service.dart';

part 'dashboard_provider.g.dart';

class DashboardData {
  final Subscription? subscription;
  final MaintenanceVisit? nextVisit;
  final List<Invoice> invoices;

  DashboardData({
    this.subscription,
    this.nextVisit,
    required this.invoices,
  });
}

@riverpod
Future<DashboardData> dashboard(DashboardRef ref) async {
  // Get the current user
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    // Get customer's subscriptions
    final subscriptions = await ref
        .read(subscriptionServiceProvider)
        .getCustomerSubscriptions(user.id);

    // If no subscription, return empty data
    if (subscriptions.isEmpty) {
      return DashboardData(invoices: []);
    }

    // Use the first active subscription (or the first one if none are active)
    final activeSubscriptions = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
    final subscription = activeSubscriptions.isNotEmpty
        ? activeSubscriptions.first
        : subscriptions.first;

    // Get the next maintenance visit
    final nextVisit = await ref
        .read(appointmentServiceProvider)
        .getNextMaintenanceVisit(subscription.id);

    // Get recent invoices
    final invoices = await ref
        .read(invoiceServiceProvider)
        .getInvoicesForSubscription(subscription.id, limit: 5);

    return DashboardData(
      subscription: subscription,
      nextVisit: nextVisit,
      invoices: invoices,
    );
  } catch (e) {
    throw Exception('Failed to load dashboard data: ${e.toString()}');
  }
} 