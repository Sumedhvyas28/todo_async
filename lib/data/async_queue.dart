import 'dart:async';
import 'dart:collection';
import '../models/task_model.dart';

class AsyncTaskQueue {
  final Queue<Task> _queue = Queue<Task>();
  final int _processingDelay;
  final int _maxRetries;
  bool _isProcessing = false;
  final Function(Task) _processCallback;
  final Function(Task, dynamic) _onErrorCallback;
  final Function(Task) _onSuccessCallback;

  AsyncTaskQueue({
    required Function(Task) processCallback,
    required Function(Task, dynamic) onErrorCallback,
    required Function(Task) onSuccessCallback,
    int processingDelay = 5,
    int maxRetries = 3,
  })  : _processCallback = processCallback,
        _onErrorCallback = onErrorCallback,
        _onSuccessCallback = onSuccessCallback,
        _processingDelay = processingDelay,
        _maxRetries = maxRetries;

  void enqueue(Task task) {
    _queue.add(task);
    if (!_isProcessing) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    final task = _queue.removeFirst();

    try {
      await Future.delayed(Duration(seconds: _processingDelay));

      _processCallback(task);

      _onSuccessCallback(task);
    } catch (error) {
      if (task.retryCount < _maxRetries) {
        final retryTask = task.copyWith(retryCount: task.retryCount + 1);
        _queue.add(retryTask);
        _onErrorCallback(task, error);
      } else {
        _onErrorCallback(task, 'Max retries exceeded: $error');
      }
    }

    _processQueue();
  }

  bool get isEmpty => _queue.isEmpty;

  int get length => _queue.length;

  void clear() {
    _queue.clear();
    _isProcessing = false;
  }
}
