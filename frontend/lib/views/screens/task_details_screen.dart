import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/comment.dart';
import '../../models/member.dart';
import '../../models/task.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/comment_viewmodel.dart';
import '../../viewmodels/manage_members_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../widgets/create_task_bottom_sheet.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final Task task;
  final String projectId;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.projectId,
  });

  @override
  ConsumerState<TaskDetailsScreen> createState() =>
      _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  Comment? _replyToComment;

  /// Generates initials from a member's name (up to 2 characters).
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(commentViewModelProvider(widget.task.id).notifier)
        .addComment(
          taskId: widget.task.id,
          content: text,
          parentId: _replyToComment?.id,
        );

    _commentController.clear();
    _commentFocusNode.unfocus();
    setState(() {
      _replyToComment = null;
    });
  }

  void _showMembersModal(BuildContext context, List<Member> members) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDFCFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Membres du projet (${members.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F3035),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF2F3035),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (members.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Aucun membre trouvé',
                      style: TextStyle(color: Color(0xFFB1B1B1)),
                    ),
                  ),
                )
              else
                ...members.map(
                  (member) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF87941),
                      child: Text(
                        _getInitials(member.name),
                        style: const TextStyle(
                          color: Color(0xFFFDFCFC),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F3035),
                      ),
                    ),
                    subtitle: Text(
                      member.email,
                      style: const TextStyle(color: Color(0xFF57423A)),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87941).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        _roleLabelFr(member.role),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF87941),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  /// Translates a role key into a French label.
  String _roleLabelFr(String role) {
    switch (role) {
      case 'owner':
        return 'Propriétaire';
      case 'admin':
        return 'Admin';
      case 'member':
        return 'Membre';
      case 'viewer':
        return 'Observateur';
      default:
        return role;
    }
  }

  /// Formats a [DateTime] into a human-readable relative string.
  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskStateAsync = ref.watch(taskViewModelProvider);
    // Try to find the latest version of the task from the state.
    final currentTask = taskStateAsync.valueOrNull?.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    ) ?? widget.task;
    final comments = ref.watch(
      commentViewModelProvider(currentTask.id),
    );
    final dueDateStr = currentTask.dueDate ?? 'Pas de date';

    // Retrieve current user ID
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.valueOrNull;
    final currentUserId = currentUser?.id.toString() ?? '';

    // Load real project members from the API.
    final membersState = ref.watch(manageMembersViewModelProvider(widget.projectId));
    final members = membersState.members;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2F3035)),
        title: const Text(
          'Détails de la tâche',
          style: TextStyle(
            color: Color(0xFF2F3035),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF2F3035),
            ),
            color: const Color(0xFFFDFCFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xFFE6E4E6)),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                showCreateTaskBottomSheet(
                  context,
                  widget.projectId,
                  taskToEdit: currentTask,
                );
              } else if (value == 'delete') {
                ref
                    .read(taskViewModelProvider.notifier)
                    .deleteTask(currentTask.id);
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Color(0xFF2F3035),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Modifier',
                      style: TextStyle(
                        color: Color(0xFF2F3035),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFA5000A),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Color(0xFFA5000A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Sticky comment input bar at the bottom.
      bottomNavigationBar: _CommentInputBar(
        controller: _commentController,
        focusNode: _commentFocusNode,
        onSubmit: _submitComment,
        replyToComment: _replyToComment,
        onCancelReply: () {
          setState(() {
            _replyToComment = null;
          });
        },
      ),
      floatingActionButton: !currentTask.isDone
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFF87941),
              foregroundColor: const Color(0xFFFDFCFC),
              onPressed: () {
                ref
                    .read(taskViewModelProvider.notifier)
                    .toggleTaskCompletion(currentTask.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text(
                'Valider la tâche',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Priority Badge ---
            Align(
              alignment: Alignment.centerLeft,
              child: _DetailPriorityBadge(
                priority: currentTask.priority,
              ),
            ),
            const SizedBox(height: 16.0),

            // --- Title ---
            Text(
              currentTask.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: currentTask.isDone
                    ? const Color(0xFFB1B1B1)
                    : const Color(0xFF2F3035),
                decoration: currentTask.isDone
                    ? TextDecoration.lineThrough
                    : null,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24.0),

            const Divider(
              color: Color(0xFFE6E4E6),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 24.0),

            // --- Status and Due Date ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF57423A),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: currentTask.isDone
                                  ? const Color(0xFFB1B1B1)
                                  : const Color(0xFFF87941),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            currentTask.isDone ? 'Done' : 'To Do',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2F3035),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DUE DATE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF57423A),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF57423A),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            dueDateStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2F3035),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),

            // --- Description ---
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF57423A),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              currentTask.description?.isNotEmpty == true
                  ? currentTask.description!
                  : 'Aucune description pour cette tâche.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2F3035),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32.0),

            // --- Members Button ---
            InkWell(
              onTap: () => _showMembersModal(context, members),
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6E4E6)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF87941),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Color(0xFFFDFCFC),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Members',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2F3035),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${members.length} membres',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF57423A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF57423A),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // --- Comments Section ---
            _CommentsSection(
              comments: comments,
              formatTimeAgo: _formatTimeAgo,
              currentUserId: currentUserId,
              onReply: (comment) {
                setState(() {
                  _replyToComment = comment;
                });
                _commentFocusNode.requestFocus();
              },
              onDelete: (commentId) {
                ref
                    .read(commentViewModelProvider(currentTask.id).notifier)
                    .deleteComment(commentId);
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comments Section Widget
// ---------------------------------------------------------------------------

class _CommentsSection extends StatelessWidget {
  final List<Comment> comments;
  final String Function(DateTime) formatTimeAgo;
  final String currentUserId;
  final ValueChanged<Comment> onReply;
  final ValueChanged<String> onDelete;

  const _CommentsSection({
    required this.comments,
    required this.formatTimeAgo,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Only display root comments here; replies are rendered nested under their parents.
    final rootComments = comments.where((c) => c.parentId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Commentaires (${comments.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2F3035),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 20.0),

        if (rootComments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'Aucun commentaire. Soyez le premier à réagir !',
                style: TextStyle(color: Color(0xFFB1B1B1)),
              ),
            ),
          )
        else
          ...rootComments.map(
            (comment) => _CommentTreeItem(
              comment: comment,
              timeAgo: formatTimeAgo(comment.createdAt),
              currentUserId: currentUserId,
              onReply: onReply,
              onDelete: onDelete,
              formatTimeAgo: formatTimeAgo,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Comment Tree Item Widget (Handles nested rendering)
// ---------------------------------------------------------------------------

class _CommentTreeItem extends StatelessWidget {
  final Comment comment;
  final String timeAgo;
  final String currentUserId;
  final ValueChanged<Comment> onReply;
  final ValueChanged<String> onDelete;
  final String Function(DateTime) formatTimeAgo;

  const _CommentTreeItem({
    required this.comment,
    required this.timeAgo,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
    required this.formatTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentItem(
          comment: comment,
          timeAgo: timeAgo,
          currentUserId: currentUserId,
          onReply: onReply,
          onDelete: onDelete,
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color(0xFFE6E4E6),
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                children: comment.replies
                    .map(
                      (reply) => Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: _CommentItem(
                          comment: reply,
                          timeAgo: formatTimeAgo(reply.createdAt),
                          currentUserId: currentUserId,
                          onReply: onReply,
                          onDelete: onDelete,
                          isReply: true,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single Comment Item Widget
// ---------------------------------------------------------------------------

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final String timeAgo;
  final String currentUserId;
  final ValueChanged<Comment> onReply;
  final ValueChanged<String> onDelete;
  final bool isReply;

  const _CommentItem({
    required this.comment,
    required this.timeAgo,
    required this.currentUserId,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = comment.userId == currentUserId;
    final hasValidAvatar = comment.avatarUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundColor: const Color(0xFFF87941),
            backgroundImage: hasValidAvatar ? NetworkImage(comment.avatarUrl) : null,
            child: !hasValidAvatar
                ? Text(
                    _getInitials(comment.authorName),
                    style: TextStyle(
                      color: const Color(0xFFFDFCFC),
                      fontWeight: FontWeight.bold,
                      fontSize: isReply ? 11 : 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12.0),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + time + actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: TextStyle(
                              fontSize: isReply ? 13 : 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F3035),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            comment.authorHandle,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFB1B1B1),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB1B1B1),
                          ),
                        ),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Color(0xFFA5000A),
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 8.0),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFFFDFCFC),
                                  title: const Text('Supprimer le commentaire ?'),
                                  content: const Text(
                                      'Voulez-vous vraiment supprimer ce commentaire ? Cette action est irréversible.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Annuler',
                                        style: TextStyle(color: Color(0xFF2F3035)),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        onDelete(comment.id);
                                      },
                                      child: const Text(
                                        'Supprimer',
                                        style: TextStyle(color: Color(0xFFA5000A)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),

                // Comment text
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: isReply ? 13 : 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2F3035),
                    height: 1.4,
                  ),
                ),
                if (!isReply) ...[
                  const SizedBox(height: 4.0),
                  GestureDetector(
                    onTap: () => onReply(comment),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Répondre',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFF87941),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky Comment Input Bar
// ---------------------------------------------------------------------------

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final Comment? replyToComment;
  final VoidCallback onCancelReply;

  const _CommentInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    this.replyToComment,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFCFC),
        border: Border(
          top: BorderSide(color: Color(0xFFE6E4E6), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply-to header info bar
          if (replyToComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: const Color(0xFFF87941).withValues(alpha: 0.08),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2F3035)),
                        children: [
                          const TextSpan(text: 'Réponse à '),
                          TextSpan(
                            text: replyToComment!.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF57423A),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: bottomPadding + 12.0,
            ),
            child: Row(
              children: [
                // Text field
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2F3035),
                    ),
                    decoration: InputDecoration(
                      hintText: replyToComment != null
                          ? 'Écrire une réponse...'
                          : 'Écrire un commentaire...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFB1B1B1),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFDFCFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide:
                            const BorderSide(color: Color(0xFFE6E4E6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFF87941),
                          width: 1.5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Send button — Precious Persimmon primary color
                GestureDetector(
                  onTap: onSubmit,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF87941),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFFFDFCFC),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPriorityBadge extends StatelessWidget {
  final int priority;

  const _DetailPriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color bgColor;
    final Color textColor;
    final IconData? icon;

    switch (priority) {
      case 3:
        label = 'High Priority';
        bgColor = const Color(0xFFFFE0D6);
        textColor = const Color(0xFFA5000A);
        icon = Icons.error_outline;
        break;
      case 1:
        label = 'Basse';
        bgColor = const Color(0xFFE6E4E6);
        textColor = const Color(0xFF2F3035);
        icon = null;
        break;
      case 2:
      default:
        label = 'Normale';
        bgColor = const Color(0xFFFFF0EA);
        textColor = const Color(0xFFF87941);
        icon = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

