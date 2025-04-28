import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pureflow/core/models/invoice.dart';

part 'invoice_service.g.dart';

class InvoiceService {
  final SupabaseClient _client;

  InvoiceService(this._client);

  /// Get an invoice by ID
  Future<Invoice> getInvoice(String id) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('id', id)
        .single();
    
    return Invoice.fromJson(response);
  }

  /// Get all invoices for a subscription
  Future<List<Invoice>> getInvoicesForSubscription(
    String subscriptionId, {
    int limit = 10,
  }) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('subscription_id', subscriptionId)
        .order('due_on', ascending: false)
        .limit(limit);
    
    return response.map((json) => Invoice.fromJson(json)).toList();
  }

  /// Get all overdue invoices for a subscription
  Future<List<Invoice>> getOverdueInvoices(String subscriptionId) async {
    final today = DateTime.now().toIso8601String();
    final response = await _client
        .from('invoices')
        .select()
        .eq('subscription_id', subscriptionId)
        .eq('status', 'pending')
        .lt('due_on', today)
        .order('due_on');
    
    return response.map((json) => Invoice.fromJson(json)).toList();
  }

  /// Mark invoice as paid
  Future<void> markInvoiceAsPaid(
    String invoiceId, {
    required String paymentMethod,
  }) async {
    await _client.from('invoices').update({
      'status': 'paid',
      'paid_on': DateTime.now().toIso8601String(),
      'payment_method': paymentMethod,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', invoiceId);
  }

  /// Generate PDF invoice URL
  Future<String> getInvoicePdfUrl(String invoiceId) async {
    final response = await _client
        .from('invoices')
        .select('pdf_url')
        .eq('id', invoiceId)
        .single();
    
    return response['pdf_url'] as String;
  }

  /// Get invoice by invoice number
  Future<Invoice?> getInvoiceByNumber(String invoiceNumber) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('invoice_number', invoiceNumber)
        .maybeSingle();
    
    if (response == null) return null;
    return Invoice.fromJson(response);
  }
}

@riverpod
InvoiceService invoiceService(InvoiceServiceRef ref) {
  return InvoiceService(Supabase.instance.client);
} 