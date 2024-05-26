import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api/eh.dart';
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
  Map<int, GalleryMetadataSingle> meta = {};
  bool _isFetching = false;
  List<int> peddingGids = [];
  List<String> peddingTokens = [];
  late Timer _pingTimer;
  bool _inited = false;
  bool get inited => _inited;
  bool _need_closed = false;
  bool _wait_closed = false;
  void clear() {
    tasks.clear();
    _channel?.stream.drain();
    _channel?.sink.close();
    _closed = true;
  }

  void fetchMeta() async {
    if (_isFetching) return;
    try {
      if (peddingGids.isEmpty) return;
      _isFetching = true;
      final re = (await api.getMetaInfo(peddingGids, peddingTokens)).unwrap();
      for (final e in re.metas.entries) {
        if (e.value.ok) {
          meta[e.key] = e.value.unwrap();
          final index = peddingGids.indexOf(e.key);
          if (index > -1) {
            peddingGids.removeAt(index);
            peddingTokens.removeAt(index);
          }
        } else {
          _log.warning("Gallery id ${e.key}:", e.value.unwrapErr());
        }
      }
      listener.tryEmit("task_meta_updated", null);
    } catch (e) {
      _log.warning("Failed to fetch metadatas:", e);
    }
    _isFetching = false;
  }

  void addToTasksList(Task task, TaskStatus status) {
    if (task.type == TaskType.download && !meta.containsKey(task.gid)) {
      if (peddingGids.contains(task.gid)) {
        final index = peddingGids.indexOf(task.gid);
        if (peddingTokens[index]! != task.token) {
          peddingTokens[index] = task.token;
        }
      } else {
        peddingGids.add(task.gid);
        peddingTokens.add(task.token);
      }
    }
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
            fetchMeta();
          } else if (type == "new_task") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            tasks[task.id] = TaskDetail(
              base: task,
              status: TaskStatus.wait,
            );
            addToTasksList(task, TaskStatus.wait);
            listener.tryEmit("task_list_changed", null);
            fetchMeta();
          } else if (type == "task_started") {
            final task = Task.fromJson(data["detail"] as Map<String, dynamic>);
            tasks.update(task.id, (value) {
              value.status = TaskStatus.running;
              tasksList.remove(task.id);
              tasksList.add(task.id);
              return value;
            }, ifAbsent: () {
              addToTasksList(task, TaskStatus.running);
              fetchMeta();
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
              fetchMeta();
            }
          } else if (type == "task_progress") {
            final task =
                TaskProgress.fromJson(data["detail"] as Map<String, dynamic>);
            if (tasks.containsKey(task.taskId)) {
              tasks.update(task.taskId, (value) {
                value.progress = task.detail;
                return value;
              });
              listener.tryEmit("task_progress_updated", task.taskId);
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
          _log.warning("Error processing task message: $e, event: $event");
        }
      }, onError: (e) {
        _log.warning("Task websocket error: $e");
        if (_allowReconnect && !_need_closed) {
          _log.info("Reconnecting to task server in 5 seconds");
          _reconnectTimer = Timer(const Duration(seconds: 5), () {
            _reconnectTimer = null;
            connect();
          });
        }
        if (_wait_closed) {
          _wait_closed = false;
        }
      }, onDone: () {
        _log.warning(
            "WenSocket closed: ${_channel?.closeCode} ${_channel?.closeReason}");
        if (_allowReconnect && !_need_closed) {
          _log.info("Reconnecting to task server in 5 seconds");
          _reconnectTimer = Timer(const Duration(seconds: 5), () {
            _reconnectTimer = null;
            connect();
          });
        }
        if (_wait_closed) {
          _wait_closed = false;
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

  void _onLifeCycleChanged(dynamic arg) {
    final state = arg as AppLifecycleState?;
    if (state == null) return;
    if (state == AppLifecycleState.resumed) {
      try {
        _channel?.sink.add("{\"type\":\"ping\"}");
      } catch (e) {
        _log.warning("Failed to send ping when onResumed: $e");
      }
    }
  }

  void init() {
    _inited = true;
    listener.on("lifecycle", _onLifeCycleChanged);
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      try {
        _channel?.sink.add("{\"type\":\"ping\"}");
      } catch (e) {
        _log.warning("Failed to send ping: $e");
      }
      _pingTimer = timer;
    });
  }

  FutureOr<bool> _waitClosed() {
    if (!_wait_closed) return true;
    return Future.delayed(const Duration(milliseconds: 10), _waitClosed);
  }

  Future<bool> waitClosed() {
    return Future.microtask(_waitClosed);
  }

  Future<void> refresh() async {
    if (_channel != null) {
      _need_closed = true;
      _wait_closed = true;
      _channel!.sink.add("{\"type\":\"close\"}");
      await waitClosed();
    }
    _channel?.sink.close();
    _channel = null;
    _closed = true;
    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
      _reconnectTimer = null;
    }
    tasks.clear();
    listener.tryEmit("task_list_changed", null);
    await connect();
  }
}
