import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract.freezed.dart';
part 'contract.g.dart';

@freezed
class Contract with _$Contract {
  factory Contract({
    required String id,
    required String subscriptionId,
    required String fileUrl,
    required String status,
    required DateTime createdAt,
    DateTime? signedAt,
    @JsonKey(includeFromJson: true, includeToJson: false)
        Map<String, dynamic>? subscription,
  }) = _Contract;

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
} 