import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

enum SubscriptionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('cancelled')
  cancelled,
}

enum ContractStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('signed')
  signed,
  @JsonValue('expired')
  expired,
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    @JsonKey(name: 'customer_id') required String customerId,
    required SubscriptionStatus status,
    required String plan,
    @JsonKey(name: 'price_monthly') required double priceMonthly,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'next_billing_date') DateTime? nextBillingDate,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => 
      _$SubscriptionFromJson(json);
}

@freezed
class Contract with _$Contract {
  const factory Contract({
    required String id,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'file_url') required String fileUrl,
    @JsonKey(name: 'signed_at') DateTime? signedAt,
    required ContractStatus status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) => 
      _$ContractFromJson(json);
} 