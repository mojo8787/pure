import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pureflow/features/dashboard/presentation/screens/schedule_visit_screen.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  testWidgets('shows date and time pickers', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const ScheduleVisitScreen(),
        ),
      ),
    );

    // Assert
    expect(find.text('Select Date and Time'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Select Time'), findsOneWidget);
  });

  testWidgets('shows notes field', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const ScheduleVisitScreen(),
        ),
      ),
    );

    // Assert
    expect(find.text('Additional Notes'), findsOneWidget);
    expect(
      find.byType(TextFormField),
      findsOneWidget,
    );
  });

  testWidgets('shows error when date and time not selected', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const ScheduleVisitScreen(),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('Schedule Visit'));
    await tester.pump();

    // Assert
    expect(find.text('Please select both date and time'), findsOneWidget);
  });

  testWidgets('schedules visit successfully', (WidgetTester tester) async {
    // Arrange
    mockSupabaseClient.mockRpcResponse('schedule_maintenance_visit', 'new-visit-id');

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: const ScheduleVisitScreen(),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('Select Date'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();

    await tester.tap(find.text('Select Time'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();

    await tester.enterText(
      find.byType(TextFormField),
      'Test visit notes',
    );
    await tester.pump();

    await tester.tap(find.text('Schedule Visit'));
    await tester.pump();

    // Assert
    expect(find.text('Visit scheduled successfully'), findsOneWidget);
  });
}

class MockSupabaseClient extends Mock implements SupabaseClient {
  final Map<String, dynamic> _mockResponses = {};

  void mockRpcResponse(String functionName, dynamic response) {
    _mockResponses[functionName] = response;
  }

  @override
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    return _mockResponses[functionName];
  }
} 