import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_visit.freezed.dart';
part 'maintenance_visit.g.dart';

@freezed
class MaintenanceVisit with _$MaintenanceVisit {
  const factory MaintenanceVisit({
    required String id,
    required String subscriptionId,
    required DateTime scheduledFor,
    String? technicianId,
    required String status,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) = _MaintenanceVisit;

  factory MaintenanceVisit.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceVisitFromJson(json);
} 