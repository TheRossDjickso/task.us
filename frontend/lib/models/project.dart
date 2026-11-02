// Model representing a collaborative project.
// It is defined immutably to comply with solid design
// principles and avoid side effects.
class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String iconName;
  final int completedTasks;
  final int totalTasks;
  final List<String> memberAvatars;
  final String updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.iconName,
    required this.completedTasks,
    required this.totalTasks,
    required this.memberAvatars,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Active',
      priority: json['priority'] ?? 'Normal',
      iconName: json['iconName'] ?? 'folder',
      completedTasks: json['completedTasks'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      memberAvatars: List<String>.from(json['memberAvatars'] ?? []),
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  // Copies the current object with some optional modifications.
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? iconName,
    int? completedTasks,
    int? totalTasks,
    List<String>? memberAvatars,
    String? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      iconName: iconName ?? this.iconName,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      memberAvatars: memberAvatars ?? this.memberAvatars,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
