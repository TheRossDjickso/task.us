import '../models/member.dart';
import '../models/task.dart';
import 'api_client.dart';

/// Service responsible for all task-related API calls.
/// Uses the project's default list to create tasks and
/// relies on the `is_done` field to separate To Do from Done.
class TaskService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches all tasks for a project by getting the project details
  /// and extracting tasks from its lists.
  Future<Map<String, dynamic>> getTasksForProject(String projectId) async {
    try {
      final response = await _apiClient.dio.get('/api/projects/$projectId');

      if (response.statusCode == 200) {
        final data = response.data;
        final lists = data['lists'] as List<dynamic>? ?? [];
        final List<Task> allTasks = [];
        String? defaultListId;

        // Extract tasks from all lists and find the default list ID.
        for (final list in lists) {
          final listId = list['id']?.toString() ?? '';
          // Use the first list as the default list for creating new tasks.
          defaultListId ??= listId;

          final tasks = list['tasks'] as List<dynamic>? ?? [];
          for (final taskJson in tasks) {
            allTasks.add(Task.fromJson(taskJson));
          }
        }

        // Parse project members from the response
        final List<Member> projectMembers = [];
        final ownerJson = data['owner'];
        if (ownerJson != null) {
          projectMembers.add(Member(
            id: ownerJson['id']?.toString() ?? '',
            name: ownerJson['full_name'] ?? '',
            email: ownerJson['email'] ?? '',
            avatarUrl: ownerJson['avatar_url'] ?? 'https://ui-avatars.com/api/?name=${ownerJson['full_name'] ?? 'U'}&background=random',
            role: 'owner',
          ));
        }

        final memberships = data['memberships'] as List<dynamic>? ?? [];
        for (final membership in memberships) {
          final userJson = membership['user'];
          if (userJson != null) {
            final userId = userJson['id']?.toString() ?? '';
            // Avoid adding owner twice if they are also in memberships
            if (projectMembers.any((m) => m.id == userId)) continue;

            projectMembers.add(Member(
              id: userId,
              name: userJson['full_name'] ?? '',
              email: userJson['email'] ?? '',
              avatarUrl: userJson['avatar_url'] ?? 'https://ui-avatars.com/api/?name=${userJson['full_name'] ?? 'U'}&background=random',
              role: membership['role'] ?? 'member',
            ));
          }
        }

        return {
          'tasks': allTasks,
          'defaultListId': defaultListId,
          'members': projectMembers,
        };
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  /// Creates a new task in the specified list.
  Future<Task> createTask({
    required String listId,
    required String title,
    String? description,
    int priority = 1,
    String? assignedTo,
    String? dueDate,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/lists/$listId/tasks',
        data: {
          'title': title,
          if (description != null && description.isNotEmpty) 'description': description,
          'priority': priority,
          if (assignedTo != null && assignedTo.isNotEmpty) 'assigned_to': int.tryParse(assignedTo),
          if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
        },
      );
      if (response.statusCode == 201) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  /// Toggles the is_done status of a task.
  Future<Task> toggleDone(String taskId) async {
    try {
      final response = await _apiClient.dio.patch('/api/tasks/$taskId/done');
      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('Failed to toggle task status');
      }
    } catch (e) {
      throw Exception('Error toggling task: $e');
    }
  }

  /// Deletes a task by its ID.
  Future<void> deleteTask(String taskId) async {
    try {
      final response = await _apiClient.dio.delete('/api/tasks/$taskId');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  /// Updates a task's details.
  Future<Task> updateTask({
    required String taskId,
    required String title,
    String? description,
    int priority = 1,
    String? assignedTo,
    String? dueDate,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/tasks/$taskId',
        data: {
          'title': title,
          'description': description ?? '',
          'priority': priority,
          'assigned_to': assignedTo != null && assignedTo.isNotEmpty ? int.tryParse(assignedTo) : null,
          'due_date': dueDate,
        },
      );
      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  /// Fetches a single task by its ID.
  Future<Task> getTask(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/api/tasks/$taskId');
      if (response.statusCode == 200) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch task');
      }
    } catch (e) {
      throw Exception('Error fetching task: $e');
    }
  }
}
