import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/todo.dart';
import '../components/todo_form.dart';
import '../components/todo_list.dart';
import 'todo_detail_screen.dart';

class TodoListScreen extends HookConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCompletedTodos = useState(false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(
              showCompletedTodos.value
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
            ),
            onPressed: () {
              showCompletedTodos.value = !showCompletedTodos.value;
            },
            tooltip: showCompletedTodos.value
                ? 'Showing all todos'
                : 'Showing active todos',
          ),
        ],
      ),
      body: TodoList(
        showCompleted: showCompletedTodos.value,
        onTodoTap: (todo) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TodoDetailScreen(todoId: todo.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTodoBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTodoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create New Todo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TodoForm(
                onSuccess: (_) {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 