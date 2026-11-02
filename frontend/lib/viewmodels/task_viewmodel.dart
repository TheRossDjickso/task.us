import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'project_viewmodel.dart';

/// State holding the list of tasks, the default list ID, and members
/// needed for creating new tasks in the project.
class TaskState {
  final List<Task> tasks;
  final String? defaultListId;
  final List<Member> members;

  const TaskState({
    this.tasks = const [],
    this.defaultListId,
    this.members = const [],
  });

  TaskState copyWith({
    List<Task>? tasks,
    String? defaultListId,
    List<Member>? members,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      defaultListId: defaultListId ?? this.defaultListId,
      members: members ?? this.members,
    );
  }
}

/// ViewModel that manages tasks for a specific project.
/// Connects to the backend via TaskService and provides
/// reactive state updates to the UI.
class TaskViewModel extends StateNotifier<AsyncValue<TaskState>> {
  final TaskService _taskService;
  final Ref _ref;
  String? _currentProjectId;

  TaskViewModel(this._taskService, this._ref) : super(const AsyncValue.loading());

  /// Loads all tasks for a given project from the API.
  Future<void> loadTasks(String projectId) async {
    _currentProjectId = projectId;
    try {
      state = const AsyncValue.loading();
      final result = await _taskService.getTasksForProject(projectId);
      final tasks = result['tasks'] as List<Task>;
      final defaultListId = result['defaultListId'] as String?;
      final members = result['members'] as List<Member>? ?? [];

      state = AsyncValue.data(TaskState(
        tasks: tasks,
        defaultListId: defaultListId,
        members: members,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a new task in the project's default list.
  Future<void> addTask({
    required String title,
    String? description,
    int priority = 1,
    String? assignedTo,
    String? dueDate,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.defaultListId == null) return;

    // Optimistically update the project total tasks count.
    if (_currentProjectId != null) {
      _ref.read(projectViewModelProvider.notifier).updateTaskCounts(
            _currentProjectId!,
            totalDelta: 1,
          );
    }

    try {
      final newTask = await _taskService.createTask(
        listId: currentState.defaultListId!,
        title: title,
        description: description,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );
      state = AsyncValue.data(currentState.copyWith(
        tasks: [...currentState.tasks, newTask],
      ));

      // Re-fetch project counts to stay in perfect sync
      if (_currentProjectId != null) {
        _ref.read(projectViewModelProvider.notifier).loadProjects();
      }
    } catch (e) {
      // Revert optimistic count update on failure
      if (_currentProjectId != null) {
        _ref.read(projectViewModelProvider.notifier).updateTaskCounts(
              _currentProjectId!,
              totalDelta: -1,
            );
      }
      rethrow;
    }
  }

  /// Toggles the is_done status of a task via the API
  /// and updates the local state optimistically.
  Future<void> toggleTaskCompletion(String taskId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final task = currentState.tasks.firstWhere((t) => t.id == taskId);
    final isNowDone = !task.isDone;

    // Optimistic update: flip the local state immediately.
    final optimisticTasks = currentState.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(isDone: isNowDone);
      }
      return t;
    }).toList();
    state = AsyncValue.data(currentState.copyWith(tasks: optimisticTasks));

    // Optimistically update the project completed tasks count
    if (_currentProjectId != null) {
      _ref.read(projectViewModelProvider.notifier).updateTaskCounts(
            _currentProjectId!,
            completedDelta: isNowDone ? 1 : -1,
          );
    }

    try {
      await _taskService.toggleDone(taskId);
      // Re-fetch project counts to stay in perfect sync
      if (_currentProjectId != null) {
        _ref.read(projectViewModelProvider.notifier).loadProjects();
      }
    } catch (e) {
      // Revert task list to original state on failure.
      state = AsyncValue.data(currentState);
      // Revert project completed count update
      if (_currentProjectId != null) {
        _ref.read(projectViewModelProvider.notifier).updateTaskCounts(
              _currentProjectId!,
              completedDelta: isNowDone ? -1 : 1,
            );
      }
      rethrow;
    }
  }

  /// Deletes a task via the API and removes it from local state.
  Future<void> deleteTask(String taskId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final task = currentState.tasks.firstWhere((t) => t.id == taskId);
    final wasDone = task.isDone;

    // Optimistic removal.
    final filteredTasks = currentState.tasks
        .where((t) => t.id != taskId)
        .toList();
    state = AsyncValue.data(currentState.copyWith(tasks: filteredTasks));

    // Optimistically update the project counts
    if (_currentProjectId != null) {
      _ref.read(projectViewModelProvider.notifier).updateTaskCounts(
            _currentProjectId!,
            completedDelta: wasDone ? -1 : 0,
            totalDelta: -1,
          );
    }

    try {
      await _taskService.deleteTask(taskId);
      // Re-fetch project counts to stay in perfect sync
      if (_currentProjectId != null) {
        _ref.read(projectViewModelProvider.notifier).loadProjects();
      }
    } catch (e) {
      // Revert on failure.
      state = AsyncValue.data(currentState);
      if (_currentProjectId != null) {
        _ref.read(projectViewModelProvider.notifier).updateTaskCounts(
              _currentProjectId!,
              completedDelta: wasDone ? 1 : 0,
              totalDelta: 1,
            );
      }
      rethrow;
    }
  }

  /// Updates task details via the API and updates the local state.
  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    int priority = 1,
    String? assignedTo,
    String? dueDate,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Optimistically update locally.
    final updatedTasks = currentState.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          title: title,
          description: description,
          priority: priority,
          assignedTo: assignedTo,
          dueDate: dueDate,
        );
      }
      return task;
    }).toList();
    state = AsyncValue.data(currentState.copyWith(tasks: updatedTasks));

    try {
      final updatedTask = await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );
      
      // Update with the actual task from backend just in case.
      final finalTasks = currentState.tasks.map((task) {
        if (task.id == taskId) {
          return updatedTask;
        }
        return task;
      }).toList();
      state = AsyncValue.data(currentState.copyWith(tasks: finalTasks));
    } catch (e) {
      // Revert on failure.
      state = AsyncValue.data(currentState);
      rethrow;
    }
  }
}

// Provider for the task service.
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

// Global provider of the task state managed by the ViewModel.
final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, AsyncValue<TaskState>>((ref) {
  final service = ref.watch(taskServiceProvider);
  return TaskViewModel(service, ref);
});
