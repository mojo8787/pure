import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/todo.dart';
import '../../providers/todo_providers.dart';

class TodoForm extends HookConsumerWidget {
  const TodoForm({
    super.key,
    this.initialTodo,
    this.onSuccess,
  });

  final Todo? initialTodo;
  final void Function(Todo todo)? onSuccess;

  bool get isEditing => initialTodo != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: initialTodo?.title ?? '');
    final descriptionController = useTextEditingController(
      text: initialTodo?.description ?? '',
    );
    final priorityNotifier = useState(initialTodo?.priority ?? TodoPriority.medium);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    final todoNotifier = ref.watch(todoNotifierProvider.notifier);
    final todoState = ref.watch(todoNotifierProvider);

    ref.listen(todoNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && next?.hasValue == true) {
        if (onSuccess != null) {
          onSuccess!(Todo(id: '', title: ''));
        }
        
        if (!isEditing) {
          // Reset form if creating a new todo
          titleController.clear();
          descriptionController.clear();
          priorityNotifier.value = TodoPriority.medium;
        }
      }
    });

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter todo title',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Enter todo description',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildPrioritySelector(priorityNotifier),
          const SizedBox(height: 24),
          if (todoState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  if (isEditing) {
                    await todoNotifier.updateTodo(
                      todoId: initialTodo!.id,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      priority: priorityNotifier.value,
                    );
                  } else {
                    await todoNotifier.createTodo(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      priority: priorityNotifier.value,
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Update Todo' : 'Create Todo'),
            ),
          if (todoState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                todoState.error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector(ValueNotifier<TodoPriority> priorityNotifier) {
    return Row(
      children: [
        _buildPriorityOption(
          label: 'Low',
          value: TodoPriority.low,
          color: Colors.green,
          selected: priorityNotifier.value == TodoPriority.low,
          onTap: () => priorityNotifier.value = TodoPriority.low,
        ),
        const SizedBox(width: 8),
        _buildPriorityOption(
          label: 'Medium',
          value: TodoPriority.medium,
          color: Colors.orange,
          selected: priorityNotifier.value == TodoPriority.medium,
          onTap: () => priorityNotifier.value = TodoPriority.medium,
        ),
        const SizedBox(width: 8),
        _buildPriorityOption(
          label: 'High',
          value: TodoPriority.high,
          color: Colors.red,
          selected: priorityNotifier.value == TodoPriority.high,
          onTap: () => priorityNotifier.value = TodoPriority.high,
        ),
      ],
    );
  }

  Widget _buildPriorityOption({
    required String label,
    required TodoPriority value,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : null,
            border: Border.all(
              color: selected ? color : Colors.grey.withOpacity(0.5),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : null,
                  color: selected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 