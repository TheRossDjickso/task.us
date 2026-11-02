import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import 'project_viewmodel.dart';

class SearchState {
  final String query;
  final bool newestFirst;

  const SearchState({
    this.query = '',
    this.newestFirst = true,
  });

  SearchState copyWith({
    String? query,
    bool? newestFirst,
  }) {
    return SearchState(
      query: query ?? this.query,
      newestFirst: newestFirst ?? this.newestFirst,
    );
  }
}

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel() : super(const SearchState());

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void toggleSortOrder() {
    state = state.copyWith(newestFirst: !state.newestFirst);
  }
}

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel();
});

// Helper for parsing date from mocked string
DateTime _parseUpdatedAt(String val) {
  final now = DateTime.now();
  final lower = val.toLowerCase();
  if (lower.contains('just now') || lower.contains('today')) {
    return now;
  }
  if (lower.contains('2h ago') || lower.contains('hours ago')) {
    return now.subtract(const Duration(hours: 2));
  }
  final parts = val.split(' ');
  if (parts.length >= 2) {
    final months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };
    final mStr = parts[0].toLowerCase().substring(0, 3);
    final month = months[mStr];
    final day = int.tryParse(parts[1]);
    if (month != null && day != null) {
      return DateTime(now.year, month, day);
    }
  }
  return DateTime.tryParse(val) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

final filteredProjectsProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projectsAsync = ref.watch(projectViewModelProvider);
  final searchState = ref.watch(searchViewModelProvider);

  return projectsAsync.whenData((projects) {
    // Filter
    final filtered = projects.where((p) {
      final q = searchState.query.trim().toLowerCase();
      if (q.isEmpty) {
        return true;
      }
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    // Sort
    filtered.sort((a, b) {
      final dateA = _parseUpdatedAt(a.updatedAt);
      final dateB = _parseUpdatedAt(b.updatedAt);
      if (searchState.newestFirst) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  });
});
