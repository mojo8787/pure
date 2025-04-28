import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pureflow/core/models/subscription.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:pureflow/features/subscriptions/providers/subscription_providers.dart';
import 'package:pureflow/shared/widgets/error_text.dart';
import 'package:pureflow/shared/widgets/loading_indicator.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(userSubscriptionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildSubscriptionsList(context, subscriptions);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => _buildEmptyState(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.addSubscription),
        icon: const Icon(Icons.add),
        label: const Text('New Subscription'),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.water_drop_outlined,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Demo Mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'This is a demonstration of the subscription management interface. Try adding a subscription by tapping the button below.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push(Routes.addSubscription),
            child: const Text('Add Subscription'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubscriptionsList(BuildContext context, List<Subscription> subscriptions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return _SubscriptionCard(
          subscription: subscription,
          onTap: () => context.push(Routes.subscriptionDetail.replaceFirst(':id', subscription.id)),
        );
      },
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  
  const _SubscriptionCard({
    required this.subscription,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subscription.plan,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _buildStatusChip(context, subscription.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${subscription.priceMonthly.toStringAsFixed(2)}/month',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    subscription.nextBillingDate != null
                        ? 'Next billing: ${_formatDate(subscription.nextBillingDate!)}'
                        : 'Not yet active',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context, SubscriptionStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case SubscriptionStatus.active:
        color = Colors.green;
        label = 'Active';
      case SubscriptionStatus.pending:
        color = Colors.orange;
        label = 'Pending';
      case SubscriptionStatus.paused:
        color = Colors.blue;
        label = 'Paused';
      case SubscriptionStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return '${date.month}/${date.day}/${date.year}';
  }
} 