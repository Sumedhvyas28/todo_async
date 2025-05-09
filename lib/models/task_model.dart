import 'package:equatable/equatable.dart';

enum TaskStatus { queued, uploaded, failed }

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final TaskStatus status;
  final int retryCount;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.status = TaskStatus.queued,
    this.retryCount = 0,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    TaskStatus? status,
    int? retryCount,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'retryCount': retryCount,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.queued,
      ),
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }

  @override
  List<Object> get props => [
        id,
        title,
        description,
        createdAt,
        status,
        retryCount,
      ];
}
