import 'package:flutter/material.dart';

import '../../models/project.dart';

// Card representing an individual project.
// Supports a featured or standard design, aligned with
// the bento design of the Task.us mobile app.
class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isFeatured;
  final VoidCallback? onTap;
  final void Function(String)? onDelete;
  final void Function(String)? onManageMembers;

  const ProjectCard({
    super.key,
    required this.project,
    this.isFeatured = false,
    this.onTap,
    this.onDelete,
    this.onManageMembers,
  });

  // Maps the text icon name to Flutter IconData.
  IconData _getIconData(String name) {
    switch (name) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'folder_open':
        return Icons.folder_open;
      case 'query_stats':
        return Icons.query_stats;
      case 'terminal':
        return Icons.terminal;
      case 'brush':
        return Icons.brush;
      default:
        return Icons.folder;
    }
  }

  // Builds the top row with the icon and status tag.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isFeatured
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final iconBgColor = isFeatured
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project icon container.
        Container(
          width: isFeatured ? 48.0 : 40.0,
          height: isFeatured ? 48.0 : 40.0,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            _getIconData(project.iconName),
            color: iconColor,
            size: isFeatured ? 24.0 : 20.0,
          ),
        ),
        // Tag or options menu on the right.
        Row(
          children: [
            _buildStatusTag(context),
              if (onDelete != null || onManageMembers != null)
                Transform.translate(
                  offset: const Offset(8.0, -2.0),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  onSelected: (value) {
                    if (value == 'delete' && onDelete != null) {
                      onDelete!(project.id);
                    } else if (value == 'manage_members' && onManageMembers != null) {
                      onManageMembers!(project.id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      if (onManageMembers != null)
                        const PopupMenuItem(
                          value: 'manage_members',
                          child: Text('Manage Members'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete Project',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ];
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Project status or priority tag.
  Widget _buildStatusTag(BuildContext context) {
    final theme = Theme.of(context);
    final isHigh = project.priority.toLowerCase() == 'high';
    final dotColor = isHigh
        ? theme.colorScheme.primary
        : const Color(0xFFB1B1B1);
    final labelColor = isHigh
        ? theme.colorScheme.primary
        : const Color(0xFF2F3035);

    if (isFeatured) {
      // Designs the priority row with a colored dot.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            '${project.priority} Priority',
            style: theme.textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Designs standard tags with a translucent background.
    final isPrimaryTag = project.category == 'Active' ||
        project.category == 'Dev';
    final tagColor = isPrimaryTag
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(9999.0),
      ),
      child: Text(
        project.category,
        style: theme.textTheme.labelMedium?.copyWith(
          color: tagColor,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Generates the aligned team avatar stack.
  Widget _buildAvatarStack(BuildContext context, double radius) {
    final theme = Theme.of(context);
    final limit = isFeatured ? 3 : 2;
    final displayCount = project.memberAvatars.take(limit).toList();
    final double overlap = radius * 1.2;
    final List<Widget> children = [];

    for (int i = 0; i < displayCount.length; i++) {
      children.add(
        Positioned(
          left: i * overlap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(displayCount[i]),
            ),
          ),
        ),
      );
    }

    final int remaining = project.memberAvatars.length - limit;
    if (remaining > 0) {
      children.add(
        Positioned(
          left: displayCount.length * overlap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: theme.colorScheme.outlineVariant,
              child: Text(
                '+$remaining',
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final double totalWidth = (displayCount.length * overlap) +
        (remaining > 0 ? (radius * 2 + 4) : (radius * 2));

    return SizedBox(
      width: totalWidth,
      height: radius * 2 + 4,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = project.totalTasks > 0
        ? project.completedTasks / project.totalTasks
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A2F3035), // 4% Neutral
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16.0),
            // Project title.
            Text(
              project.title,
              style: isFeatured
                  ? theme.textTheme.headlineMedium
                  : theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
            ),
            const SizedBox(height: 4.0),
            // Secondary description.
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF57423A), // Secondary neutral
              ),
            ),
            const SizedBox(height: 24.0),
            // Progress section.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                Text(
                  isFeatured
                      ? '${project.completedTasks}/${project.totalTasks} tasks'
                      : '${(progress * 100).toInt()}% Complete',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Linear progress bar.
            ClipRRect(
              borderRadius: BorderRadius.circular(9999.0),
              child: SizedBox(
                height: isFeatured ? 8.0 : 6.0,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            // Bottom row with members and update date.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAvatarStack(context, isFeatured ? 16.0 : 12.0),
                Text(
                  project.updatedAt,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
