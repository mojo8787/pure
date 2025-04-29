import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pureflow/core/models/maintenance_visit.dart';
import 'package:pureflow/features/dashboard/providers/maintenance_visits_provider.dart';
import 'package:intl/intl.dart';

class NextVisitCard extends ConsumerWidget {
  const NextVisitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceVisitsAsync = ref.watch(maintenanceVisitsProvider);

    return maintenanceVisitsAsync.when(
      data: (visits) {
        if (visits.isEmpty) {
          return _buildNoVisitsCard();
        }

        final nextVisit = visits.first;
        return _buildVisitCard(context, nextVisit);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorCard(error.toString()),
    );
  }

  Widget _buildVisitCard(BuildContext context, MaintenanceVisit visit) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Next Visit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              dateFormat.format(visit.scheduledFor),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              timeFormat.format(visit.scheduledFor),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            _buildStatusChip(visit.status),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVisitsCard() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No upcoming visits scheduled'),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Error loading visits',
              style: TextStyle(color: Colors.red.shade900),
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
} 