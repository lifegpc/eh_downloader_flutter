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
  void clear() {
    tasks.clear();
    _channel?.stream.drain();
    _channel?.sink.close();
    _closed = true;
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
              tasks[task.id] = TaskDetail(
                base: task,
                status: list.running.contains(task.id)
                    ? TaskStatus.running
                    : TaskStatus.wait,
              );
            }
          } else if (type == "new_task") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            tasks[task.id] = TaskDetail(
              base: task,
              status: TaskStatus.wait,
            );
          } else if (type == "task_started") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            tasks.update(task.id, (value) {
              value.status = TaskStatus.running;
              return value;
            },
                ifAbsent: () => TaskDetail(
                      base: task,
                      status: TaskStatus.running,
                    ));
          } else if (type == "task_finished") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            if (tasks.containsKey(task.id)) {
              tasks.update(task.id, (value) {
                value.status = TaskStatus.finished;
                return value;
              });
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
                return value;
              });
            }
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
