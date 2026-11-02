import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../models/task.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../widgets/task_list_item.dart';
import '../widgets/create_task_bottom_sheet.dart';

class TaskDashboardScreen extends ConsumerStatefulWidget {
  final Project project;

  const TaskDashboardScreen({super.key, required this.project});

  @override
  ConsumerState<TaskDashboardScreen> createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends ConsumerState<TaskDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(taskViewModelProvider.notifier).loadTasks(widget.project.id);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF87941),
              onPrimary: Color(0xFFFDFCFC),
              onSurface: Color(0xFF2F3035),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getMonthStr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getWeekdayStr(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  void _deleteProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(projectViewModelProvider.notifier)
                  .deleteProject(widget.project.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deleted successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the task sections (TO DO and DONE) from a list of tasks.
  Widget _buildTaskSections(List<Task> allTasks) {
    final String selectedDateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    
    final dayTasks = allTasks.where((task) {
      if (task.dueDate != null) {
        return task.dueDate == selectedDateStr;
      }
      if (task.createdAt != null) {
        final createdDate = task.createdAt!;
        return createdDate.year == _selectedDate.year &&
            createdDate.month == _selectedDate.month &&
            createdDate.day == _selectedDate.day;
      }
      return false;
    }).toList();

    final todoTasks = dayTasks.where((t) => !t.isDone).toList();
    final doneTasks = dayTasks.where((t) => t.isDone).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TO DO section header
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFB1B1B1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'TO DO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F3035),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${todoTasks.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F3035),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        if (todoTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'No pending tasks.',
              style: TextStyle(color: Color(0xFFB1B1B1)),
            ),
          ),
        ...todoTasks.map((task) => TaskListItem(task: task, projectId: widget.project.id)),
        const SizedBox(height: 32.0),

        // DONE section header
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFB1B1B1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'DONE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F3035),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${doneTasks.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F3035),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        if (doneTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'No completed tasks yet.',
              style: TextStyle(color: Color(0xFFB1B1B1)),
            ),
          ),
        ...doneTasks.map((task) => TaskListItem(task: task, projectId: widget.project.id)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskStateAsync = ref.watch(taskViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2F3035)),
        title: const Text(
          'Task Dashboard',
          style: TextStyle(
            color: Color(0xFF2F3035),
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2F3035)),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteProject(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete Project',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF87941),
        foregroundColor: const Color(0xFFFDFCFC),
        onPressed: () {
          final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
          showCreateTaskBottomSheet(
            context,
            widget.project.id,
            initialDueDate: dateStr,
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedDate.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F3035),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF87941),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getMonthStr(_selectedDate.month)}\'${_selectedDate.year.toString().substring(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB1B1B1),
                        ),
                      ),
                      Text(
                        _getWeekdayStr(_selectedDate.weekday),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F3035),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Project title
            Text(
              widget.project.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F3035),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32.0),
            // Task sections with loading/error handling
            taskStateAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFFF87941),
                  ),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load tasks',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(taskViewModelProvider.notifier).loadTasks(widget.project.id);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (taskState) => _buildTaskSections(taskState.tasks),
            ),
          ],
        ),
      ),
    );
  }
}
