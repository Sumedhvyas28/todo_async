import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/task_repository.dart';
import '../../models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<Task>>? _tasksSubscription;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(TaskState.initial()) {
    on<TasksFetched>(_onTasksFetched);
    on<TaskCreated>(_onTaskCreated);
    on<TasksStreamUpdated>(_onTasksStreamUpdated);
  }

  Future<void> _onTasksFetched(
    TasksFetched event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.queued));
    try {
      await _tasksSubscription?.cancel();
      _tasksSubscription = _taskRepository.getTasks().listen(
            (tasks) => add(TasksStreamUpdated(tasks)),
          );
    } catch (e) {
      emit(
        state.copyWith(status: TaskStatus.failed, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onTaskCreated(
    TaskCreated event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TaskStatus.queued));
      await _taskRepository.createTask(
        title: event.title,
        description: event.description,
      );

      emit(state.copyWith(status: TaskStatus.queued));
    } catch (e) {
      emit(
        state.copyWith(status: TaskStatus.failed, errorMessage: e.toString()),
      );
      emit(state.copyWith(status: TaskStatus.queued));
    }
  }

  void _onTasksStreamUpdated(
    TasksStreamUpdated event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(status: TaskStatus.uploaded, tasks: event.tasks));
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
