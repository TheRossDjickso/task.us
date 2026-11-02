import '../models/member.dart';
import 'api_client.dart';

/// Service handling all project member/invitation-related API calls.
class MemberService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches the list of members (from the project details endpoint).
  /// The API returns owner + memberships; we merge them into a flat list.
  Future<List<Member>> getMembers(String projectId) async {
    try {
      final response = await _apiClient.dio.get('/api/projects/$projectId');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<Member> members = [];

        // Parse the project owner.
        final ownerJson = data['owner'];
        if (ownerJson != null) {
          members.add(Member(
            id: ownerJson['id']?.toString() ?? '',
            name: ownerJson['full_name'] ?? '',
            email: ownerJson['email'] ?? '',
            avatarUrl: ownerJson['avatar_url'] ??
                'https://ui-avatars.com/api/?name=${ownerJson['full_name'] ?? 'U'}&background=random',
            role: 'owner',
            isPending: false,
          ));
        }

        // Parse collaborators from the memberships array.
        final memberships = data['memberships'] as List<dynamic>? ?? [];
        for (final membership in memberships) {
          final userJson = membership['user'];
          if (userJson != null) {
            final userId = userJson['id']?.toString() ?? '';

            // Avoid adding owner twice if they appear in memberships.
            if (members.any((m) => m.id == userId)) continue;

            members.add(Member(
              id: userId,
              name: userJson['full_name'] ?? '',
              email: userJson['email'] ?? '',
              avatarUrl: userJson['avatar_url'] ??
                  'https://ui-avatars.com/api/?name=${userJson['full_name'] ?? 'U'}&background=random',
              role: membership['role'] ?? 'member',
              isPending: membership['status'] == 'pending',
            ));
          }
        }

        return members;
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      throw Exception('Error fetching members: $e');
    }
  }

  /// Invites a new member to the project by email.
  /// Backend: POST /api/projects/:id/members  { email, role }
  Future<void> inviteMember(String projectId, String email, String role) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/projects/$projectId/members',
        data: {
          'email': email,
          'role': role,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to invite member');
      }
    } catch (e) {
      throw Exception('Error inviting member: $e');
    }
  }

  /// Updates a member's role in the project.
  /// Backend: PUT /api/projects/:id/members/:userId  { role }
  Future<void> updateMemberRole(
      String projectId, String userId, String role) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/projects/$projectId/members/$userId',
        data: {'role': role},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update member role');
      }
    } catch (e) {
      throw Exception('Error updating member role: $e');
    }
  }

  /// Removes a member from the project.
  /// Backend: DELETE /api/projects/:id/members/:userId
  Future<void> removeMember(String projectId, String userId) async {
    try {
      final response = await _apiClient.dio.delete(
        '/api/projects/$projectId/members/$userId',
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to remove member');
      }
    } catch (e) {
      throw Exception('Error removing member: $e');
    }
  }
}
