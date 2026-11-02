import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import '../services/comment_service.dart';

class CommentViewModel extends StateNotifier<List<Comment>> {
  final CommentService _commentService;
  final String _taskId;

  CommentViewModel(this._commentService, this._taskId) : super([]) {
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final comments = await _commentService.getComments(_taskId);
      // Backend returns them in chronological order. We can keep it or reverse it.
      // Usually comments read top to bottom, but task details screen has them listed.
      // Let's keep the backend order or reverse it if needed. 
      // The current UI iterates through them. We can display them as returned.
      state = comments;
    } catch (e, stack) {
      print('Error loading comments for task $_taskId: $e');
      print(stack);
    }
  }

  /// Adds a new comment and updates the state.
  Future<void> addComment({
    required String taskId,
    required String content,
    String? parentId,
  }) async {
    try {
      await _commentService.addComment(
        taskId: taskId,
        content: content,
        parentId: parentId,
      );
      // Reload from backend to construct the correct tree
      await loadComments();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a comment.
  Future<void> deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(taskId: _taskId, commentId: commentId);
      // Reload from backend to rebuild the tree
      await loadComments();
    } catch (e) {
      rethrow;
    }
  }
}

final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService();
});

final commentViewModelProvider =
    StateNotifierProvider.family<CommentViewModel, List<Comment>, String>(
  (ref, taskId) {
    final service = ref.watch(commentServiceProvider);
    return CommentViewModel(service, taskId);
  },
);
