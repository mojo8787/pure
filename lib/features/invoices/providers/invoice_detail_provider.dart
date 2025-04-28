import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/invoice.dart';
import 'package:pureflow/core/services/invoice_service.dart';

part 'invoice_detail_provider.g.dart';

class InvoiceDetailData {
  final Invoice invoice;
  final String pdfUrl;

  InvoiceDetailData({
    required this.invoice,
    required this.pdfUrl,
  });
}

@riverpod
Future<InvoiceDetailData> invoiceDetail(
  InvoiceDetailRef ref,
  String invoiceId,
) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  
  try {
    // Load invoice details
    final invoice = await invoiceService.getInvoice(invoiceId);
    
    // Get PDF URL if available
    String pdfUrl = '';
    try {
      pdfUrl = await invoiceService.getInvoicePdfUrl(invoiceId);
    } catch (_) {
      // If PDF URL retrieval fails, we can still show the invoice details
    }
    
    return InvoiceDetailData(
      invoice: invoice,
      pdfUrl: pdfUrl,
    );
  } catch (e) {
    throw Exception('Failed to load invoice: ${e.toString()}');
  }
}

@riverpod
Future<void> markInvoiceAsPaid(
  MarkInvoiceAsPaidRef ref,
  String invoiceId,
  String paymentMethod,
) async {
  final invoiceService = ref.watch(invoiceServiceProvider);
  
  try {
    await invoiceService.markInvoiceAsPaid(
      invoiceId,
      paymentMethod: paymentMethod,
    );
    
    // Refresh the invoice detail
    ref.invalidate(invoiceDetailProvider(invoiceId));
  } catch (e) {
    throw Exception('Failed to mark invoice as paid: ${e.toString()}');
  }
} 