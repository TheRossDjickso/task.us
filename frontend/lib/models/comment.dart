/// Represents a single comment on a task.
class Comment {
  final String id;
  final String taskId;
  final String userId;
  final String authorName;
  final String authorHandle;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.authorName,
    required this.authorHandle,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.replies = const [],
  });

  /// Factory constructor to parse comment from backend JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final String fullName = userJson?['full_name'] ?? 'Utilisateur inconnu';
    final String handle = '@${fullName.replaceAll(' ', '').toLowerCase()}';
    final String avatar = userJson?['avatar_url'] ?? '';

    // Handle replies recursively and robustly
    final List<Comment> repliesList = [];
    if (json['replies'] is List) {
      for (final reply in json['replies'] as List) {
        if (reply is Map) {
          repliesList.add(Comment.fromJson(Map<String, dynamic>.from(reply)));
        }
      }
    }

    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final parsedCreatedAt = rawCreatedAt != null
        ? DateTime.parse(rawCreatedAt.toString())
        : DateTime.now();

    final rawParentId = json['parent_id'] ?? json['parentId'];
    final rawTaskId = json['task_id'] ?? json['taskId'];
    final rawUserId = json['user_id'] ?? json['userId'];

    return Comment(
      id: json['id']?.toString() ?? '',
      taskId: rawTaskId?.toString() ?? '',
      userId: rawUserId?.toString() ?? '',
      authorName: fullName,
      authorHandle: handle,
      avatarUrl: avatar,
      content: json['content'] ?? '',
      createdAt: parsedCreatedAt,
      parentId: rawParentId?.toString(),
      replies: repliesList,
    );
  }
}
