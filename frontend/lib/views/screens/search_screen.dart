import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../widgets/project_card.dart';
import 'task_dashboard_screen.dart';
import 'manage_members_screen.dart';

// Premium Search screen showcasing a search input, filters,
// and result cards utilizing the Bento Grid project card widget.
// The state is managed via SearchViewModel.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchViewModelProvider.notifier).updateQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteProject(BuildContext context, String id) {
    ref.read(projectViewModelProvider.notifier).deleteProject(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project deleted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _manageMembers(BuildContext context, String projectId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageMembersScreen(projectId: projectId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);
    final filteredProjectsAsync = ref.watch(filteredProjectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F3035),
                ),
              ),
              const SizedBox(height: 20.0),
              // Search input field.
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Color(0xFF2F3035)),
                decoration: InputDecoration(
                  hintText: 'Search projects, tags, description...',
                  hintStyle: const TextStyle(color: Color(0xFFB1B1B1)),
                  prefixIcon: const Icon(
                    Icons.search_outlined,
                    color: Color(0xFFB1B1B1),
                  ),
                  suffixIcon: searchState.query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFFB1B1B1),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFE6E4E6),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFFF87941),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Filter and results row.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  filteredProjectsAsync.when(
                    data: (projects) => Text(
                      '${projects.length} results found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFB1B1B1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Error'),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF87941),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(
                          color: Color(0xFFFDFCFC),
                        ),
                      ),
                    ),
                    onPressed: () {
                      ref.read(searchViewModelProvider.notifier).toggleSortOrder();
                    },
                    icon: Icon(
                      searchState.newestFirst
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 16.0,
                    ),
                    label: Text(
                      searchState.newestFirst ? 'Newest first' : 'Oldest first',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Results list using ProjectCard.
              Expanded(
                child: filteredProjectsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (filteredProjects) => filteredProjects.isEmpty
                      ? Center(
                          child: Text(
                            'No projects found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFFB1B1B1),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredProjects.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16.0),
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            return ProjectCard(
                              project: project,
                              isFeatured: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TaskDashboardScreen(project: project),
                                  ),
                                );
                              },
                              onDelete: (id) => _deleteProject(context, id),
                              onManageMembers: (id) =>
                                  _manageMembers(context, id),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
