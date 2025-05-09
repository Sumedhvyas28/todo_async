import 'package:equatable/equatable.dart';
import '../../models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TasksFetched extends TaskEvent {}

class TaskCreated extends TaskEvent {
  final String title;
  final String description;

  const TaskCreated({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}

class TasksStreamUpdated extends TaskEvent {
  final List<Task> tasks;

  const TasksStreamUpdated(this.tasks);

  @override
  List<Object> get props => [tasks];
}
