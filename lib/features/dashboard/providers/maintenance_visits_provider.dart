import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pureflow/core/models/maintenance_visit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'maintenance_visits_provider.g.dart';

@riverpod
class MaintenanceVisits extends _$MaintenanceVisits {
  @override
  FutureOr<List<MaintenanceVisit>> build() async {
    return _fetchMaintenanceVisits();
  }

  Future<List<MaintenanceVisit>> _fetchMaintenanceVisits() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await Supabase.instance.client
          .rpc('get_upcoming_maintenance_visits', params: {
        'p_customer_id': user.id,
        'p_limit': 5,
      });

      return response.map((json) => MaintenanceVisit.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching maintenance visits: $e');
      return [];
    }
  }

  Future<void> scheduleVisit({
    required String subscriptionId,
    required DateTime scheduledFor,
    String? notes,
  }) async {
    try {
      await Supabase.instance.client.rpc('schedule_maintenance_visit', params: {
        'p_subscription_id': subscriptionId,
        'p_scheduled_for': scheduledFor.toIso8601String(),
        'p_notes': notes,
      });

      // Refresh the visits list
      await refresh();
    } catch (e) {
      print('Error scheduling visit: $e');
      rethrow;
    }
  }

  Future<void> updateVisitStatus({
    required String visitId,
    required String status,
    String? notes,
  }) async {
    try {
      await Supabase.instance.client.rpc('update_maintenance_visit_status', params: {
        'p_visit_id': visitId,
        'p_status': status,
        'p_notes': notes,
      });

      // Refresh the visits list
      await refresh();
    } catch (e) {
      print('Error updating visit status: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMaintenanceVisits());
  }
} 