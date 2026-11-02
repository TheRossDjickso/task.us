import '../models/comment.dart';
import 'api_client.dart';

/// Service responsible for comment-related API calls.
class CommentService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches all comments for a task.
  Future<List<Comment>> getComments(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/api/tasks/$taskId/comments');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  /// Adds a comment to a task.
  Future<Comment> addComment({
    required String taskId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/tasks/$taskId/comments',
        data: {
          'content': content,
          if (parentId != null) 'parent_id': int.tryParse(parentId),
        },
      );
      if (response.statusCode == 201) {
        return Comment.fromJson(response.data);
      }
      throw Exception('Failed to add comment');
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Updates an existing comment.
  Future<Comment> updateComment({
    required String taskId,
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/tasks/$taskId/comments/$commentId',
        data: {'content': content},
      );
      if (response.statusCode == 200) {
        return Comment.fromJson(response.data);
      }
      throw Exception('Failed to update comment');
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  /// Deletes a comment.
  Future<void> deleteComment({
    required String taskId,
    required String commentId,
  }) async {
    try {
      await _apiClient.dio.delete('/api/tasks/$taskId/comments/$commentId');
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
