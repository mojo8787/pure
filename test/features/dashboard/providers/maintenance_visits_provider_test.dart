import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pureflow/features/dashboard/providers/maintenance_visits_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient])
void main() {
  late ProviderContainer container;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    container = ProviderContainer(
      overrides: [
        supabaseClientProvider.overrideWithValue(mockSupabaseClient),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MaintenanceVisitsProvider', () {
    test('fetches maintenance visits successfully', () async {
      // Arrange
      final mockVisits = [
        {
          'id': '1',
          'subscription_id': 'sub1',
          'scheduled_for': '2024-03-20T10:00:00Z',
          'status': 'scheduled',
          'notes': 'Test visit',
        }
      ];

      when(mockSupabaseClient.rpc(
        'get_upcoming_maintenance_visits',
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockVisits);

      // Act
      final visits = await container.read(maintenanceVisitsProvider.future);

      // Assert
      expect(visits.length, 1);
      expect(visits.first.id, '1');
      expect(visits.first.status, 'scheduled');
    });

    test('schedules visit successfully', () async {
      // Arrange
      final mockVisitId = 'new-visit-id';
      when(mockSupabaseClient.rpc(
        'schedule_maintenance_visit',
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockVisitId);

      // Act
      await container.read(maintenanceVisitsProvider.notifier).scheduleVisit(
            subscriptionId: 'sub1',
            scheduledFor: DateTime.now(),
            notes: 'Test visit',
          );

      // Assert
      verify(mockSupabaseClient.rpc(
        'schedule_maintenance_visit',
        params: anyNamed('params'),
      )).called(1);
    });

    test('handles errors when fetching visits', () async {
      // Arrange
      when(mockSupabaseClient.rpc(
        'get_upcoming_maintenance_visits',
        params: anyNamed('params'),
      )).thenThrow(Exception('Error fetching visits'));

      // Act & Assert
      expect(
        () => container.read(maintenanceVisitsProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class MockSupabaseClient extends Mock implements SupabaseClient {
  final List<String> rpcCalls = [];
  final Map<String, dynamic> _mockResponses = {};
  final Map<String, String> _mockErrors = {};

  void mockRpcResponse(String functionName, dynamic response) {
    _mockResponses[functionName] = response;
  }

  void mockRpcError(String functionName, String error) {
    _mockErrors[functionName] = error;
  }

  @override
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    rpcCalls.add(functionName);
    
    if (_mockErrors.containsKey(functionName)) {
      throw Exception(_mockErrors[functionName]);
    }
    
    return _mockResponses[functionName];
  }
} 