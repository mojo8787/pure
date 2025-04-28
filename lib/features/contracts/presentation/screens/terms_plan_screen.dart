import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pureflow/core/config/app_config.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:pureflow/features/contracts/providers/contract_provider.dart';
import 'package:pureflow/shared/constants/colors.dart';
import 'package:pureflow/shared/widgets/error_text.dart';

class TermsPlanScreen extends HookConsumerWidget {
  const TermsPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReadTerms = useState(false);
    final isLoading = useState(false);
    final termsError = useState<String?>(null);

    // Get monthly price from config
    final appConfig = ref.watch(appConfigProvider);
    final monthlyPrice = appConfig.monthlyPrice;
    final currencyCode = appConfig.currencyCode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Plan'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Plans section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context,
                    title: 'Standard Plan',
                    price: monthlyPrice,
                    currency: currencyCode,
                    features: [
                      'Professional installation',
                      'Regular filter maintenance',
                      'Customer support',
                      'Water quality monitoring',
                    ],
                    isSelected: true,
                  ),
                ],
              ),
            ),
            
            // Terms & Conditions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please read and accept our terms and conditions.',
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
            
            // PDF Viewer for terms
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SfPdfViewer.asset(
                    'assets/contracts/ro_standard.pdf',
                    onDocumentLoaded: (_) => hasReadTerms.value = true,
                    onDocumentLoadFailed: (details) {
                      termsError.value = 'Failed to load terms: ${details.error}';
                    },
                  ),
                ),
              ),
            ),
            
            // Error message
            if (termsError.value != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorText(error: termsError.value!),
              ),
            
            // Accept & Continue button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: hasReadTerms.value,
                        onChanged: (value) => hasReadTerms.value = value ?? false,
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the terms and conditions',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasReadTerms.value && !isLoading.value
                          ? () async {
                              isLoading.value = true;
                              try {
                                // Create draft subscription
                                await ref
                                    .read(contractProviderProvider.notifier)
                                    .createDraftSubscription(
                                      plan: 'Standard Plan',
                                      priceMonthly: monthlyPrice,
                                    );
                                if (context.mounted) {
                                  context.go(Routes.contractSign);
                                }
                              } catch (e) {
                                termsError.value = e.toString();
                              } finally {
                                isLoading.value = false;
                              }
                            }
                          : null,
                      child: isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Agree & Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required double price,
    required String currency,
    required List<String> features,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency $price',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ month',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 