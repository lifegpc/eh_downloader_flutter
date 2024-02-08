import 'api/task.dart';

class TaskManager {
  Map<int, TaskDetail> tasks = {};
  void clear() {
    tasks.clear();
  }
}
