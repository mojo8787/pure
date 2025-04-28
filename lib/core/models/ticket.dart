import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

enum TicketStatus {
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
}

enum TicketPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

enum TicketCategory {
  @JsonValue('water_quality')
  waterQuality,
  @JsonValue('leakage')
  leakage,
  @JsonValue('installation')
  installation,
  @JsonValue('billing')
  billing,
  @JsonValue('other')
  other,
}

@freezed
class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'technician_id') String? technicianId,
    required String subject,
    required String detail,
    required TicketStatus status,
    @Default(TicketPriority.medium) TicketPriority priority,
    required TicketCategory category,
    @JsonKey(name: 'photo_urls') List<String>? photoUrls,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => 
      _$TicketFromJson(json);
}

@freezed
class TicketResponse with _$TicketResponse {
  const factory TicketResponse({
    required String id,
    @JsonKey(name: 'ticket_id') required String ticketId,
    @JsonKey(name: 'user_id') required String userId,
    required String message,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'photo_urls') List<String>? photoUrls,
  }) = _TicketResponse;

  factory TicketResponse.fromJson(Map<String, dynamic> json) => 
      _$TicketResponseFromJson(json);
} 