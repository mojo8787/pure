import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import 'package:pureflow/core/models/invoice.dart';
import 'package:pureflow/features/invoices/providers/invoice_detail_provider.dart';
import 'package:pureflow/shared/constants/colors.dart';
import 'package:pureflow/shared/widgets/error_text.dart';

class InvoiceDetailScreen extends HookConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceState = ref.watch(invoiceDetailProvider(invoiceId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share invoice functionality
            },
          ),
        ],
      ),
      body: invoiceState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ErrorText(error: error.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(invoiceDetailProvider(invoiceId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _buildInvoiceDetail(context, data),
      ),
    );
  }

  Widget _buildInvoiceDetail(BuildContext context, InvoiceDetailData data) {
    final dateFormat = DateFormat('MMM d, y');
    final invoice = data.invoice;
    
    return Column(
      children: [
        // Invoice summary
        _buildInvoiceHeader(context, invoice),
        
        // PDF viewer
        Expanded(
          child: data.pdfUrl.isEmpty
              ? const Center(child: Text('PDF not available'))
              : SfPdfViewer.network(
                  data.pdfUrl,
                  enableDoubleTapZooming: true,
                  canShowScrollHead: false,
                  pageLayoutMode: PdfPageLayoutMode.single,
                ),
        ),
        
        // Pay now button for pending invoices
        if (invoice.status == InvoiceStatus.pending || 
            invoice.status == InvoiceStatus.overdue)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Payment functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Pay Now'),
            ),
          ),
      ],
    );
  }

  Widget _buildInvoiceHeader(BuildContext context, Invoice invoice) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    
    String statusText;
    Color statusColor;
    
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusText = 'Paid';
        statusColor = AppColors.success;
        break;
      case InvoiceStatus.pending:
        statusText = 'Pending';
        statusColor = AppColors.warning;
        break;
      case InvoiceStatus.overdue:
        statusText = 'Overdue';
        statusColor = Colors.red;
        break;
      case InvoiceStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = Colors.grey;
        break;
      case InvoiceStatus.draft:
        statusText = 'Draft';
        statusColor = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.invoiceNumber ?? 'Invoice #${invoice.id.substring(0, 8)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due Date: ${dateFormat.format(invoice.dueOn)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'JOD ${invoice.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (invoice.paidOn != null) 
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Paid on: ${dateFormat.format(invoice.paidOn!)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
} 