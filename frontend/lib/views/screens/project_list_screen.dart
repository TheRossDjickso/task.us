import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../widgets/add_project_dialog.dart';
import '../widgets/project_card.dart';
import 'manage_members_screen.dart';
import 'task_dashboard_screen.dart';

// Main screen showing the list of projects.
// Implements a responsive design adapting a bento grid on
// large screens to a simple vertical list on mobile phones.
class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  // Opens the dialog to enter the new project data.
  void _openAddProjectDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return const AddProjectDialog();
      },
    );

    if (result != null && context.mounted) {
      try {
        await ref.read(projectViewModelProvider.notifier).addProject(
          result['title']!,
          result['description']!,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // Deletes a project after confirmation.
  void _deleteProject(BuildContext context, WidgetRef ref, String id) {
    ref.read(projectViewModelProvider.notifier).deleteProject(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project deleted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Navigates to the Manage Members screen.
  void _manageMembers(BuildContext context, String projectId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageMembersScreen(projectId: projectId),
      ),
    );
  }

  // Generates the bento design adapted to the screen width.
  Widget _buildBentoGrid({
    required BuildContext context,
    required WidgetRef ref,
    required List<Project> projects,
    required double width,
  }) {
    final theme = Theme.of(context);

    if (projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0),
          child: Text(
            'No active projects',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (width >= 900) {
      // 3-column design for desktop screens.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ProjectCard(
                  project: projects[0],
                  isFeatured: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDashboardScreen(project: projects[0]),
                      ),
                    );
                  },
                  onDelete: (id) => _deleteProject(context, ref, id),
                  onManageMembers: (id) => _manageMembers(context, id),
                ),
              ),
              if (projects.length > 1) ...[
                const SizedBox(width: 24.0),
                Expanded(
                  flex: 1,
                  child: ProjectCard(
                    project: projects[1],
                    isFeatured: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskDashboardScreen(project: projects[1]),
                        ),
                      );
                    },
                    onDelete: (id) => _deleteProject(context, ref, id),
                    onManageMembers: (id) => _manageMembers(context, id),
                  ),
                ),
              ],
            ],
          ),
          if (projects.length > 2) ...[
            const SizedBox(height: 24.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24.0,
                mainAxisSpacing: 24.0,
                childAspectRatio: 0.82,
              ),
              itemCount: projects.length - 2,
              itemBuilder: (context, index) {
                return ProjectCard(
                  project: projects[index + 2],
                  isFeatured: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDashboardScreen(project: projects[index + 2]),
                      ),
                    );
                  },
                  onDelete: (id) => _deleteProject(context, ref, id),
                  onManageMembers: (id) => _manageMembers(context, id),
                );
              },
            ),
          ],
        ],
      );
    } else if (width >= 600) {
      // 2-column design for tablets.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectCard(
            project: projects[0],
            isFeatured: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskDashboardScreen(project: projects[0]),
                ),
              );
            },
            onDelete: (id) => _deleteProject(context, ref, id),
            onManageMembers: (id) => _manageMembers(context, id),
          ),
          if (projects.length > 1) ...[
            const SizedBox(height: 24.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24.0,
                mainAxisSpacing: 24.0,
                childAspectRatio: 0.85,
              ),
              itemCount: projects.length - 1,
              itemBuilder: (context, index) {
                return ProjectCard(
                  project: projects[index + 1],
                  isFeatured: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDashboardScreen(project: projects[index + 1]),
                      ),
                    );
                  },
                  onDelete: (id) => _deleteProject(context, ref, id),
                  onManageMembers: (id) => _manageMembers(context, id),
                );
              },
            ),
          ],
        ],
      );
    } else {
      // 1-column design for mobiles.
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16.0),
        itemBuilder: (context, index) {
          return ProjectCard(
            project: projects[index],
            isFeatured: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TaskDashboardScreen(project: projects[index]),
                ),
              );
            },
            onDelete: (id) => _deleteProject(context, ref, id),
            onManageMembers: (id) => _manageMembers(context, id),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectViewModelProvider);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;

        return Scaffold(
          // Exclusive FAB for the mobile view.
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 4.0,
                  onPressed: () => _openAddProjectDialog(context, ref),
                  child: const Icon(Icons.add),
                )
              : null,
          body: projectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (projects) => RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: () => ref.read(projectViewModelProvider.notifier).loadProjects(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen header.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Projects',
                                style: isMobile
                                    ? theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )
                                    : theme.textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Active collaboration hubs',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          // "Create" button only visible on desktop/tablet.
                          if (!isMobile)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => _openAddProjectDialog(context, ref),
                              icon: const Icon(Icons.add, size: 18.0),
                              label: Text(
                                'New Project',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      // Responsive list.
                      _buildBentoGrid(
                        context: context,
                        ref: ref,
                        projects: projects,
                        width: width,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
