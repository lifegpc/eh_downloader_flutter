import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api/task.dart';
import 'globals.dart';
import 'utils/websocket.dart';

final _log = Logger("TaskManager");

class TaskManager {
  Map<int, TaskDetail> tasks = {};
  WebSocketChannel? _channel;
  bool _closed = false;
  bool _allowReconnect = true;
  Timer? _reconnectTimer;
  List<int> tasksList = [];
  void clear() {
    tasks.clear();
    _channel?.stream.drain();
    _channel?.sink.close();
    _closed = true;
  }

  void addToTasksList(Task task, TaskStatus status) {
    if (status == TaskStatus.finished) {
      tasksList.add(task.id);
      return;
    }
    final index = tasksList.indexWhere((element) {
      final otask = tasks[element];
      if (otask == null) {
        return false;
      }
      if (status == TaskStatus.wait) {
        return otask.status == TaskStatus.finished;
      } else {
        return otask.status == TaskStatus.wait;
      }
    });
    if (index == -1) {
      tasksList.add(task.id);
    } else {
      tasksList.insert(index, task.id);
    }
  }

  Future<void> connect() async {
    if (auth.canManageTasks != true) return;
    try {
      _channel = await connectWebSocket(api.getTaskUrl());
      _channel!.stream.listen((event) {
        try {
          final data = jsonDecode(event) as Map<String, dynamic>;
          final type = data["type"] as String;
          if (type == "tasks") {
            final list = TaskList.fromJson(data);
            for (var task in list.tasks) {
              final status = list.running.contains(task.id)
                  ? TaskStatus.running
                  : TaskStatus.wait;
              tasks[task.id] = TaskDetail(
                base: task,
                status: status,
              );
              addToTasksList(task, status);
            }
            listener.tryEmit("task_list_changed", null);
          } else if (type == "new_task") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            tasks[task.id] = TaskDetail(
              base: task,
              status: TaskStatus.wait,
            );
            addToTasksList(task, TaskStatus.wait);
            listener.tryEmit("task_list_changed", null);
          } else if (type == "task_started") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            tasks.update(task.id, (value) {
              value.status = TaskStatus.running;
              tasksList.remove(task.id);
              tasksList.add(task.id);
              return value;
            }, ifAbsent: () {
              addToTasksList(task, TaskStatus.running);
              return TaskDetail(
                base: task,
                status: TaskStatus.running,
              );
            });
            listener.tryEmit("task_list_changed", null);
          } else if (type == "task_finished") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            if (tasks.containsKey(task.id)) {
              tasks.update(task.id, (value) {
                value.status = TaskStatus.finished;
                tasksList.remove(task.id);
                tasksList.add(task.id);
                return value;
              });
              listener.tryEmit("task_list_changed", null);
            }
          } else if (type == "task_progress") {
            final task =
                TaskProgress.fromJson(data["detail"] as Map<String, dynamic>);
            if (tasks.containsKey(task.taskId)) {
              tasks.update(task.taskId, (value) {
                value.progress = task.detail;
                return value;
              });
            }
          } else if (type == "task_updated") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            if (tasks.containsKey(task.id)) {
              tasks.update(task.id, (value) {
                value.base = task;
                return value;
              });
            }
          } else if (type == "task_error") {
            final info =
                TaskError.fromJson(data["detail"] as Map<String, dynamic>);
            if (tasks.containsKey(info.task.id)) {
              tasks.update(info.task.id, (value) {
                value.status = TaskStatus.failed;
                value.error = info.error;
                value.fataled = info.fatal;
                if (info.fatal) {
                  tasksList.remove(info.task.id);
                  tasksList.add(info.task.id);
                  listener.tryEmit("task_list_changed", null);
                }
                return value;
              });
            }
          } else if (type == "ping") {
            _channel?.sink.add("{\"type\":\"pong\"}");
          }
        } catch (e) {
          _log.warning("Error processing task message: $e");
        }
      }, onError: (e) {
        _log.warning("Task websocket error: $e");
        if (_allowReconnect) {
          _log.info("Reconnecting to task server in 5 seconds");
          _reconnectTimer = Timer(const Duration(seconds: 5), () {
            _reconnectTimer = null;
            connect();
          });
        }
      }, cancelOnError: true);
      await _channel!.ready;
      _closed = false;
      sendTaskList();
    } catch (e) {
      _channel = null;
      _log.warning("Failed to connect to task server: $e");
      if (_allowReconnect) {
        _log.info("Reconnecting to task server in 5 seconds");
        _reconnectTimer = Timer(const Duration(seconds: 5), () {
          _reconnectTimer = null;
          connect();
        });
      }
    }
  }

  void sendTaskList() {
    _channel?.sink.add("{\"type\":\"task_list\"}");
  }
}
