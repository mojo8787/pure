import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../domain/models/todo.dart';

part 'todo_service.g.dart';

@riverpod
TodoService todoService(TodoServiceRef ref) => TodoService();

class TodoService {
  final _supabase = Supabase.instance.client;
  final _tableName = 'todos';

  Future<List<Todo>> getUserTodos(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response.map((todo) => Todo.fromJson(todo)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> getTodo(String todoId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', todoId)
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> createTodo({
    required String userId,
    required String title,
    String description = '',
    TodoPriority priority = TodoPriority.medium,
  }) async {
    try {
      final newTodo = {
        'user_id': userId,
        'title': title,
        'description': description,
        'is_completed': false,
        'priority': priority.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .insert(newTodo)
          .select()
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> updateTodo({
    required String todoId,
    String? title,
    String? description,
    TodoPriority? priority,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (priority != null) updates['priority'] = priority.name;

      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', todoId)
          .select()
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> toggleTodoCompletion({
    required String todoId,
    required bool isCompleted,
  }) async {
    try {
      final updates = <String, dynamic>{
        'is_completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (isCompleted) {
        updates['completed_at'] = DateTime.now().toIso8601String();
      } else {
        updates['completed_at'] = null;
      }

      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', todoId)
          .select()
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> deleteTodo(String todoId) async {
    try {
      // Soft delete
      final response = await _supabase
          .from(_tableName)
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', todoId)
          .select()
          .single();

      return Todo.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(dynamic error) {
    if (error is PostgrestException) {
      if (error.code == 'PGRST116') {
        return AppException.notFound('Todo not found');
      } else if (error.code == 'PGRST109') {
        return AppException.validation('Invalid data provided');
      } else if (error.code == '23505') {
        return AppException.duplicated('Todo already exists');
      } else {
        return AppException.data('Database error: ${error.message}');
      }
    } else if (error is AuthException) {
      return AppException.authentication('Authentication error: ${error.message}');
    } else {
      return AppException.unknown('An unexpected error occurred: $error');
    }
  }
} 