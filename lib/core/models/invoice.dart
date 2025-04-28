import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    required double amount,
    @JsonKey(name: 'due_on') required DateTime dueOn,
    @JsonKey(name: 'pdf_url') required String pdfUrl,
    required InvoiceStatus status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'paid_on') DateTime? paidOn,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'invoice_number') String? invoiceNumber,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) => 
      _$InvoiceFromJson(json);
} 