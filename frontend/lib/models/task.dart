// Model representing a task within a project list.
// Maps directly to the backend Task model fields.
class Task {
  final String id;
  final String listId;
  final String title;
  final String? description;
  final bool isDone;
  final int priority; // 1 = low, 2 = medium, 3 = high
  final String? dueDate;
  final String? assignedTo;
  final String? createdBy;
  final DateTime? createdAt;

  const Task({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    this.isDone = false,
    this.priority = 1,
    this.dueDate,
    this.assignedTo,
    this.createdBy,
    this.createdAt,
  });

  /// Parses a Task from the backend JSON response.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      listId: json['list_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isDone: json['is_done'] ?? false,
      priority: json['priority'] ?? 1,
      dueDate: json['due_date'],
      assignedTo: json['assigned_to']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  /// Converts the task to a JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'priority': priority,
      if (dueDate != null) 'due_date': dueDate,
      if (assignedTo != null) 'assigned_to': int.tryParse(assignedTo!),
    };
  }

  Task copyWith({
    String? id,
    String? listId,
    String? title,
    String? description,
    bool? isDone,
    int? priority,
    String? dueDate,
    String? assignedTo,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
