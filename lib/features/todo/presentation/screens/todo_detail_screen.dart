import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/error_handler.dart';
import '../../domain/models/todo.dart';
import '../../providers/todo_providers.dart';
import '../components/todo_form.dart';

class TodoDetailScreen extends HookConsumerWidget {
  const TodoDetailScreen({
    super.key,
    required this.todoId,
  });

  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoProvider(todoId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, ref),
            tooltip: 'Delete Todo',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todoProvider(todoId));
          return ref.read(todoProvider(todoId).future);
        },
        child: ErrorHandler.handleAsyncValue<Todo>(
          value: todoAsync,
          onData: (todo) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodoDetails(context, todo),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Edit Todo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TodoForm(
                  initialTodo: todo,
                  onSuccess: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Todo updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          loadingBuilder: () => const Center(
            child: CircularProgressIndicator(),
          ),
          onRetry: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TodoDetailScreen(todoId: todoId),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTodoDetails(BuildContext context, Todo todo) {
    Color priorityColor;
    switch (todo.priority) {
      case TodoPriority.high:
        priorityColor = Colors.red;
        break;
      case TodoPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TodoPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                todo.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: todo.isCompleted
                      ? Colors.grey
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Checkbox(
              value: todo.isCompleted,
              onChanged: (value) {
                if (value != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(value ? 'Mark as Completed' : 'Mark as Incomplete'),
                      content: Text(
                        value 
                          ? 'Do you want to mark this todo as completed?' 
                          : 'Do you want to mark this todo as incomplete?'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => TodoDetailScreen(todoId: todo.id),
                              ),
                            );
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: priorityColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: priorityColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    todo.priority.name.toUpperCase(),
                    style: TextStyle(color: priorityColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (todo.isCompleted && todo.completedAt != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'COMPLETED',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (todo.description.isNotEmpty) ...[
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            todo.description,
            style: TextStyle(
              color: todo.isCompleted
                  ? Colors.grey
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Created: ${_formatDate(todo.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (todo.updatedAt != null)
          Text(
            'Last update: ${_formatDate(todo.updatedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (todo.isCompleted && todo.completedAt != null)
          Text(
            'Completed: ${_formatDate(todo.completedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text(
          'Are you sure you want to delete this todo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(todoNotifierProvider.notifier).deleteTodo(todoId);
              if (context.mounted) {
                Navigator.of(context).pop(); // Go back to list screen
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 