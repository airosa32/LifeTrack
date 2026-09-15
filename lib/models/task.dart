enum TaskPriority { low, medium, high, urgent }

TaskPriority taskPriorityFromString(String value) {
  return TaskPriority.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TaskPriority.medium,
  );
}

extension TaskPriorityLabel on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }

  int get sortWeight {
    switch (this) {
      case TaskPriority.urgent:
        return 0;
      case TaskPriority.high:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 3;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool completed;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.completed = false,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? completed,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: taskPriorityFromString(json['priority'] as String),
      completed: json['completed'] as bool? ?? false,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'completed': completed,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
