import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pureflow/core/models/subscription.dart';
import 'package:pureflow/features/subscriptions/providers/subscription_providers.dart';
import 'package:pureflow/shared/widgets/error_text.dart';
import 'package:pureflow/shared/widgets/loading_indicator.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  String? selectedPlanId;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Plan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: plansAsync.when(
              data: (plans) => _buildPlansList(context, plans),
              loading: () => const LoadingIndicator(),
              error: (error, stack) => Center(
                child: ErrorText(message: 'Error loading plans: $error'),
              ),
            ),
          ),
          if (subscriptionState.isLoading) 
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(),
            ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<Map<String, dynamic>> plans) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _PlanCard(
          planId: plan['id'] as String,
          name: plan['name'] as String,
          description: plan['description'] as String,
          priceMonthly: plan['price_monthly'] as double,
          features: List<String>.from(plan['features']),
          isSelected: selectedPlanId == plan['id'],
          onTap: () {
            setState(() {
              selectedPlanId = plan['id'] as String;
            });
          },
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: selectedPlanId == null 
            ? null
            : _handleSubscribe,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text('Subscribe'),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    if (selectedPlanId == null) return;
    
    final plans = await ref.read(subscriptionPlansProvider.future);
    final selectedPlan = plans.firstWhere(
      (plan) => plan['id'] == selectedPlanId,
    );
    
    final priceMonthly = selectedPlan['price_monthly'] as double;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is a demo app. In a real app, a new subscription would be created.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      );
      context.pop();
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String planId;
  final String name;
  final String description;
  final double priceMonthly;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.planId,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
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
                    name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Radio<bool>(
                    value: true,
                    groupValue: isSelected ? true : null,
                    onChanged: (_) => onTap(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${priceMonthly.toStringAsFixed(2)}/month',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(feature),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
} 