import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/error_handler.dart';
import '../../domain/models/todo.dart';
import '../../providers/todo_providers.dart';
import 'todo_item.dart';

class TodoList extends HookConsumerWidget {
  const TodoList({
    super.key,
    required this.showCompleted,
    this.onTodoTap,
  });

  final bool showCompleted;
  final void Function(Todo todo)? onTodoTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodosAsync = ref.watch(
      filteredTodosProvider(showCompleted: showCompleted),
    );

    return RefreshIndicator(
      onRefresh: () async {
        // Just wait a bit to simulate refresh
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      },
      child: _buildContent(context, filteredTodosAsync),
    );
  }

  Widget _buildContent(BuildContext context, AsyncValue<List<Todo>> todosAsync) {
    if (todosAsync.isLoading) {
      return const _LoadingState();
    }
    
    if (todosAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${todosAsync.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Refresh the screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TodoList(
                      showCompleted: showCompleted,
                      onTodoTap: onTodoTap,
                    ),
                  ),
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    final todos = todosAsync.value ?? [];
    
    if (todos.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ListView.builder(
      itemCount: todos.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onTap: onTodoTap != null ? () => onTodoTap!(todo) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showCompleted ? Icons.task : Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            showCompleted
                ? 'No todos yet'
                : 'No active todos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            showCompleted
                ? 'Create your first todo by tapping the + button'
                : 'All tasks completed!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading todos...'),
        ],
      ),
    );
  }
} 