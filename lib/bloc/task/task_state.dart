import 'package:equatable/equatable.dart';
import '../../models/task_model.dart';

class TaskState extends Equatable {
  final List<Task> tasks;
  final TaskStatus status;
  final String? errorMessage;

  const TaskState({
    required this.tasks,
    required this.status,
    this.errorMessage,
  });

  factory TaskState.initial() {
    return const TaskState(
      tasks: [],
      status: TaskStatus.uploaded,
    );
  }

  TaskState copyWith({
    List<Task>? tasks,
    TaskStatus? status,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [tasks, status, errorMessage];
}
