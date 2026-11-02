import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../services/project_service.dart';

// ViewModel that manages the list of collaborative projects.
// Provides reactive operations to read, add, and update
// projects in the application according to user interactions.
class ProjectViewModel extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectService _projectService;

  ProjectViewModel(this._projectService) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  // Loads the projects from the API.
  Future<void> loadProjects() async {
    try {
      state = const AsyncValue.loading();
      final projects = await _projectService.getProjects();
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Adds a new project via the API and updates the list.
  Future<void> addProject(String title, String description) async {
    try {
      final newProject = await _projectService.createProject(title, description);
      if (state is AsyncData) {
        final currentList = state.value!;
        state = AsyncValue.data([newProject, ...currentList]);
      } else {
        state = AsyncValue.data([newProject]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Deletes a project via the API and removes it from local state.
  Future<void> deleteProject(String id) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    // Optimistic removal from the list.
    state = AsyncValue.data(currentList.where((p) => p.id != id).toList());

    try {
      await _projectService.deleteProject(id);
    } catch (e) {
      // Revert on failure.
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }

  // Optimistically updates task counts for a given project to refresh the progress bar immediately.
  void updateTaskCounts(String projectId, {int? completedDelta, int? totalDelta}) {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    state = AsyncValue.data(currentList.map((p) {
      if (p.id == projectId) {
        final newCompleted = (p.completedTasks + (completedDelta ?? 0)).clamp(0, 99999);
        final newTotal = (p.totalTasks + (totalDelta ?? 0)).clamp(0, 99999);
        return p.copyWith(
          completedTasks: newCompleted,
          totalTasks: newTotal,
        );
      }
      return p;
    }).toList());
  }
}

// Provider for the project service.
final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

// Global provider of the project list managed by the ViewModel.
final projectViewModelProvider =
    StateNotifierProvider<ProjectViewModel, AsyncValue<List<Project>>>((ref) {
  final service = ref.watch(projectServiceProvider);
  return ProjectViewModel(service);
});
