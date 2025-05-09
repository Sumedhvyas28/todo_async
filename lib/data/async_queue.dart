import 'dart:async';
import 'dart:collection';
import '../models/task_model.dart';

// Custom async queue implementation
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
    int processingDelay = 5, // seconds
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
      // Add delay to simulate processing time
      await Future.delayed(Duration(seconds: _processingDelay));

      // Process the task
      _processCallback(task);

      // Notify success
      _onSuccessCallback(task);
    } catch (error) {
      // If retry count hasn't exceeded max, re-enqueue with incremented retry count
      if (task.retryCount < _maxRetries) {
        final retryTask = task.copyWith(retryCount: task.retryCount + 1);
        _queue.add(retryTask);
        _onErrorCallback(task, error);
      } else {
        // Max retries exceeded, notify error handler
        _onErrorCallback(task, 'Max retries exceeded: $error');
      }
    }

    // Continue processing the queue
    _processQueue();
  }

  bool get isEmpty => _queue.isEmpty;

  int get length => _queue.length;

  // Clear the queue
  void clear() {
    _queue.clear();
    _isProcessing = false;
  }
}
