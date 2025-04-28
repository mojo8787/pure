import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/todo_service.dart';
import '../domain/models/todo.dart';

part 'todo_providers.g.dart';

// Temporary test user ID - this would normally come from auth
const String _testUserId = '00000000-0000-0000-0000-000000000000';

@riverpod
Future<List<Todo>> userTodos(UserTodosRef ref) async {
  return ref.watch(todoServiceProvider).getUserTodos(_testUserId);
}

@riverpod
Future<List<Todo>> filteredTodos(FilteredTodosRef ref, {required bool showCompleted}) async {
  final todos = await ref.watch(userTodosProvider.future);
  
  if (showCompleted) {
    return todos;
  } else {
    return todos.where((todo) => !todo.isCompleted).toList();
  }
}

@riverpod
Future<Todo> todo(TodoRef ref, String todoId) async {
  return ref.watch(todoServiceProvider).getTodo(todoId);
}

@riverpod
class TodoNotifier extends _$TodoNotifier {
  @override
  FutureOr<void> build() {
    // Initial state is null - no operation in progress
  }

  Future<Todo> createTodo({
    required String title,
    String description = '',
    TodoPriority priority = TodoPriority.medium,
  }) async {
    state = const AsyncLoading();
    
    try {
      final todo = await ref.read(todoServiceProvider).createTodo(
        userId: _testUserId,
        title: title,
        description: description,
        priority: priority,
      );
      
      // Invalidate user todos to refresh the list
      ref.invalidate(userTodosProvider);
      
      state = const AsyncData(null);
      return todo;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  
  Future<Todo> updateTodo({
    required String todoId,
    String? title,
    String? description,
    TodoPriority? priority,
  }) async {
    state = const AsyncLoading();
    
    try {
      final todo = await ref.read(todoServiceProvider).updateTodo(
        todoId: todoId,
        title: title,
        description: description,
        priority: priority,
      );
      
      // Invalidate providers to refresh data
      ref.invalidate(userTodosProvider);
      ref.invalidate(todoProvider(todoId));
      
      state = const AsyncData(null);
      return todo;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  
  Future<Todo> toggleTodoCompletion({
    required String todoId,
    required bool isCompleted,
  }) async {
    state = const AsyncLoading();
    
    try {
      final todo = await ref.read(todoServiceProvider).toggleTodoCompletion(
        todoId: todoId,
        isCompleted: isCompleted,
      );
      
      // Invalidate providers to refresh data
      ref.invalidate(userTodosProvider);
      ref.invalidate(todoProvider(todoId));
      
      state = const AsyncData(null);
      return todo;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
  
  Future<Todo> deleteTodo(String todoId) async {
    state = const AsyncLoading();
    
    try {
      final todo = await ref.read(todoServiceProvider).deleteTodo(todoId);
      
      // Invalidate providers to refresh data
      ref.invalidate(userTodosProvider);
      ref.invalidate(todoProvider(todoId));
      
      state = const AsyncData(null);
      return todo;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
} 