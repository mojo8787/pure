import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

enum AppointmentType {
  @JsonValue('install')
  install,
  @JsonValue('maintenance')
  maintenance,
}

enum AppointmentStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('rescheduled')
  rescheduled,
}

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'technician_id') String? technicianId,
    @JsonKey(name: 'date_time') required DateTime dateTime,
    required AppointmentType type,
    required AppointmentStatus status,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) => 
      _$AppointmentFromJson(json);
}

@freezed
class MaintenanceVisit with _$MaintenanceVisit {
  const factory MaintenanceVisit({
    required String id,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'scheduled_for') required DateTime scheduledFor,
    @JsonKey(name: 'technician_id') String? technicianId,
    required AppointmentStatus status,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _MaintenanceVisit;

  factory MaintenanceVisit.fromJson(Map<String, dynamic> json) => 
      _$MaintenanceVisitFromJson(json);
} 