# Visit Scheduling Feature Documentation

## Overview
The Visit Scheduling feature allows customers to schedule maintenance visits for their water filter systems. This feature is a core part of the customer dashboard functionality.

## 1. Database Layer
```sql
-- Table Structure
CREATE TABLE IF NOT EXISTS maintenance_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id),
    scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
    technician_id UUID REFERENCES auth.users(id),
    status appointment_status DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Key Functions
CREATE OR REPLACE FUNCTION schedule_maintenance_visit(
    p_subscription_id UUID,
    p_scheduled_for TIMESTAMP WITH TIME ZONE,
    p_notes TEXT DEFAULT NULL
) RETURNS UUID;
```

## 2. Business Logic Layer
```dart
// MaintenanceVisitsProvider
class MaintenanceVisits extends _$MaintenanceVisits {
  // Fetch upcoming visits
  Future<List<MaintenanceVisit>> _fetchMaintenanceVisits()
  
  // Schedule new visit
  Future<void> scheduleVisit({
    required String subscriptionId,
    required DateTime scheduledFor,
    String? notes,
  })
  
  // Update visit status
  Future<void> updateVisitStatus({
    required String visitId,
    required String status,
    String? notes,
  })
}
```

## 3. UI Layer
```dart
// ScheduleVisitScreen
class ScheduleVisitScreen extends ConsumerStatefulWidget {
  // Features:
  // - Date picker (next 90 days)
  // - Time picker
  // - Notes field
  // - Form validation
  // - Loading states
  // - Error handling
  // - Success feedback
}
```

## 4. Navigation
```dart
// Routes
static const String scheduleVisit = '/schedule-visit';

// Router Configuration
GoRoute(
  path: Routes.scheduleVisit,
  builder: (context, state) => const ScheduleVisitScreen(),
)
```

## 5. User Flow
1. User clicks "Schedule Visit" in dashboard
2. User selects:
   - Date (within next 90 days)
   - Time
   - Optional notes
3. System:
   - Validates input
   - Creates visit record
   - Updates subscription
   - Shows success message
4. User returns to dashboard

## 6. Security
- Row Level Security (RLS) policies ensure:
  - Customers can only see their own visits
  - Technicians can see assigned visits
  - Admins can see all visits

## 7. Status Management
- Visit statuses:
  - `scheduled` (default)
  - `in_progress`
  - `completed`
  - `cancelled`
  - `rescheduled`

## 8. Dependencies
- `intl` for date formatting
- `go_router` for navigation
- `riverpod` for state management
- `supabase_flutter` for backend communication

## 9. Error Handling
- Form validation
- API error handling
- User feedback through:
  - Error messages
  - Loading indicators
  - Success notifications

## 10. Next Steps
1. Implement visit history view
2. Add visit cancellation
3. Add visit rescheduling
4. Implement technician assignment
5. Add visit reminders

## Implementation Notes
- The feature uses a clean architecture approach
- All database operations are handled through Supabase functions
- UI follows Material Design 3 guidelines
- State management is handled through Riverpod
- Navigation uses GoRouter for type-safe routing

## Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for full user flow
- Database function tests

## Future Enhancements
1. Calendar view for visit scheduling
2. Recurring visit scheduling
3. Visit reminders via push notifications
4. Visit history with filtering
5. Visit rescheduling with conflict detection 