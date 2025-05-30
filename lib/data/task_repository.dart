import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/data/async_queue.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'auth_repository.dart';

// for mostly task creation and memory both local and firebase

class TaskRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  late final AsyncTaskQueue _taskQueue;
  final uuid = const Uuid();
  final List<Task> _localQueuedTasks = [];

  List<Task> get localQueuedTasks => List.unmodifiable(_localQueuedTasks);
  void addLocalQueuedTask(Task task) => _localQueuedTasks.add(task);
  void removeLocalQueuedTask(String id) =>
      _localQueuedTasks.removeWhere((t) => t.id == id);

  TaskRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository {
    _taskQueue = AsyncTaskQueue(
      processCallback: (task) async => await _firestore
          .collection('users')
          .doc(_authRepository.currentUser?.uid)
          .collection('tasks')
          .doc(task.id)
          .set(task.copyWith(status: TaskStatus.uploaded).toMap()),
      onErrorCallback: (task, error) => print('Error processing task: $error'),
      onSuccessCallback: (task) {
        print('Task uploaded: ${task.id}');
        removeLocalQueuedTask(task.id);
      },
    );
  }

// Create a new Task object with a unique ID and 'queued' status
  Future<Task> createTask({
    required String title,
    required String description,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final task = Task(
      id: uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      status: TaskStatus.queued,
    );

    _taskQueue.enqueue(task);
    // Save the task locally in memory to show immediately in the UI
    addLocalQueuedTask(task);
    return task;
  }

  Stream<List<Task>> getTasks() {
    final user = _authRepository.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList(),
        );
  }

  // Mark a task as uploaded
  Future<void> markTaskAsUploaded(String taskId) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .update({'status': TaskStatus.uploaded.name});
  }
}
