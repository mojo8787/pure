import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pureflow/core/models/appointment.dart';

part 'appointment_service.g.dart';

class AppointmentService {
  final SupabaseClient _client;

  AppointmentService(this._client);

  /// Get an appointment by ID
  Future<Appointment> getAppointment(String id) async {
    final response = await _client
        .from('appointments')
        .select()
        .eq('id', id)
        .single();
    
    return Appointment.fromJson(response);
  }

  /// Get all appointments for a subscription
  Future<List<Appointment>> getSubscriptionAppointments(String subscriptionId) async {
    final response = await _client
        .from('appointments')
        .select()
        .eq('subscription_id', subscriptionId)
        .order('date_time', ascending: true);
    
    return response.map((json) => Appointment.fromJson(json)).toList();
  }

  /// Get all appointments for a technician on a specific day
  Future<List<Appointment>> getTechnicianAppointmentsForDay(
    String technicianId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final response = await _client
        .from('appointments')
        .select()
        .eq('technician_id', technicianId)
        .gte('date_time', startOfDay.toIso8601String())
        .lt('date_time', endOfDay.toIso8601String())
        .order('date_time', ascending: true);
    
    return response.map((json) => Appointment.fromJson(json)).toList();
  }

  /// Create a new appointment
  Future<Appointment> createAppointment({
    required String subscriptionId,
    required DateTime dateTime,
    required AppointmentType type,
    String? technicianId,
    String? notes,
  }) async {
    final response = await _client.from('appointments').insert({
      'subscription_id': subscriptionId,
      'technician_id': technicianId,
      'date_time': dateTime.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': 'scheduled',
      'notes': notes,
    }).select().single();
    
    return Appointment.fromJson(response);
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
    String? notes,
  }) async {
    final data = {
      'status': status.toString().split('.').last,
      'updated_at': DateTime.now().toIso8601String(),
      if (notes != null) 'notes': notes,
    };
    
    // Add status-specific timestamps
    if (status == AppointmentStatus.completed) {
      data['completed_at'] = DateTime.now().toIso8601String();
    } else if (status == AppointmentStatus.cancelled) {
      data['cancelled_at'] = DateTime.now().toIso8601String();
    }
    
    await _client.from('appointments').update(data).eq('id', id);
  }

  /// Assign technician to appointment
  Future<void> assignTechnician({
    required String appointmentId,
    required String technicianId,
  }) async {
    await _client.from('appointments').update({
      'technician_id': technicianId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);
  }

  /// Get the next scheduled maintenance visit for a subscription
  Future<MaintenanceVisit?> getNextMaintenanceVisit(String subscriptionId) async {
    final response = await _client
        .from('maintenance_visits')
        .select()
        .eq('subscription_id', subscriptionId)
        .eq('status', 'scheduled')
        .gte('scheduled_for', DateTime.now().toIso8601String())
        .order('scheduled_for', ascending: true)
        .limit(1);
    
    if (response.isEmpty) return null;
    return MaintenanceVisit.fromJson(response.first);
  }

  /// Schedule next maintenance visit (typically called by an edge function)
  Future<MaintenanceVisit> scheduleMaintenanceVisit({
    required String subscriptionId,
    required DateTime scheduledFor,
  }) async {
    final response = await _client.from('maintenance_visits').insert({
      'subscription_id': subscriptionId,
      'scheduled_for': scheduledFor.toIso8601String(),
      'status': 'scheduled',
    }).select().single();
    
    return MaintenanceVisit.fromJson(response);
  }
}

@riverpod
AppointmentService appointmentService(AppointmentServiceRef ref) {
  return AppointmentService(Supabase.instance.client);
} 