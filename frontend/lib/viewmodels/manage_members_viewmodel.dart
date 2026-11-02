import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';
import '../services/member_service.dart';

class ManageMembersState {
  final List<Member> members;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String roleFilter; // 'all', 'owner', 'admin', 'member', 'viewer'

  const ManageMembersState({
    this.members = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.roleFilter = 'all',
  });

  ManageMembersState copyWith({
    List<Member>? members,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? roleFilter,
  }) {
    return ManageMembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
    );
  }
}

class ManageMembersViewModel extends StateNotifier<ManageMembersState> {
  final MemberService _memberService;
  final String _projectId;

  ManageMembersViewModel(this._memberService, this._projectId)
      : super(const ManageMembersState()) {
    loadMembers();
  }

  /// Fetches the real member list from the backend API.
  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final members = await _memberService.getMembers(_projectId);
      state = state.copyWith(isLoading: false, members: members);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Invites a new member by email with a given role.
  Future<void> inviteMember(String email, String role) async {
    try {
      await _memberService.inviteMember(_projectId, email, role);
      // Reload the full member list to get the newly added collaborator.
      await loadMembers();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Updates a member's role and refreshes the list.
  Future<void> updateMemberRole(String memberId, String newRole) async {
    // Optimistic update.
    final previousMembers = state.members;
    state = state.copyWith(
      members: state.members.map((m) {
        if (m.id == memberId) {
          return m.copyWith(role: newRole);
        }
        return m;
      }).toList(),
    );

    try {
      await _memberService.updateMemberRole(_projectId, memberId, newRole);
    } catch (e) {
      // Revert on failure.
      state = state.copyWith(
        members: previousMembers,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Removes a member from the project.
  Future<void> removeMember(String memberId) async {
    // Optimistic removal.
    final previousMembers = state.members;
    state = state.copyWith(
      members: state.members.where((m) => m.id != memberId).toList(),
    );

    try {
      await _memberService.removeMember(_projectId, memberId);
    } catch (e) {
      // Revert on failure.
      state = state.copyWith(
        members: previousMembers,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setRoleFilter(String role) {
    state = state.copyWith(roleFilter: role);
  }

  /// Filters members by search query and role filter.
  List<Member> get filteredMembers {
    return state.members.where((member) {
      final matchesSearch =
          member.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
              member.email
                  .toLowerCase()
                  .contains(state.searchQuery.toLowerCase());
      final matchesRole =
          state.roleFilter == 'all' || member.role == state.roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }
}

// Provider for the member service.
final memberServiceProvider = Provider<MemberService>((ref) {
  return MemberService();
});

final manageMembersViewModelProvider = StateNotifierProvider.family<
    ManageMembersViewModel, ManageMembersState, String>((ref, projectId) {
  final service = ref.watch(memberServiceProvider);
  return ManageMembersViewModel(service, projectId);
});
