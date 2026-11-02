import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../screens/task_details_screen.dart';

class TaskListItem extends ConsumerWidget {
  final Task task;
  final String projectId;

  const TaskListItem({
    super.key,
    required this.task,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(task: task, projectId: projectId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFC),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE6E4E6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badge and Checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PriorityBadge(priority: task.priority),
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: task.isDone,
                  activeColor: const Color(0xFFF87941),
                  checkColor: const Color(0xFFFDFCFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  side: const BorderSide(color: Color(0xFFD6C2B9), width: 1.5),
                  onChanged: (_) {
                    ref.read(taskViewModelProvider.notifier).toggleTaskCompletion(task.id);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Task Title
          Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: task.isDone ? const Color(0xFFB1B1B1) : const Color(0xFF2F3035),
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24.0),
          // Bottom Row: Due date indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (task.dueDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF57423A)),
                    const SizedBox(width: 6),
                    Text(
                      task.dueDate!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF57423A),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

/// Visual badge showing the priority level of a task.
/// Maps the backend integer priority (1, 2, 3) to
/// color-coded labels.
class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bgColor;
    final Color textColor;

    switch (priority) {
      case 3:
        label = 'HAUTE';
        bgColor = const Color(0xFFFFE0D6);
        textColor = const Color(0xFFA5000A);
        break;
      case 2:
        label = 'NORMALE';
        bgColor = const Color(0xFFFFF0EA);
        textColor = const Color(0xFFF87941);
        break;
      case 1:
      default:
        label = 'BASSE';
        bgColor = const Color(0xFFE6E4E6);
        textColor = const Color(0xFF2F3035);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
