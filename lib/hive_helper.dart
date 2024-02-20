import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_hive/task.dart';

const String kTaskBox = 'TASK_BOX';

class HiveHelper {
  static final HiveHelper _singleton = HiveHelper._internal();

  factory HiveHelper() {
    return _singleton;
  }

  HiveHelper._internal();

  Box<Task>? tasksBox;

  Future reorder(int oldIndex, int newIndex) async {
    List<Task> newList = [];
    newList.addAll(tasksBox!.values.toList());
    final Task item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    await tasksBox!.clear();
    await tasksBox!.addAll(newList);
    return;
  }

  Future openBox() async {
    tasksBox = await Hive.openBox(kTaskBox);
  }

  Future<List<Task>> read() async {
    return tasksBox?.values.toList() ?? [];
  }

  Future create(Task newTask) async {
    return tasksBox!.add(newTask);
  }

  Future update(int index, Task updatedTask) async {
    tasksBox!.putAt(index, updatedTask);
  }

  Future delete(int index) async {
    tasksBox!.deleteAt(index);
  }
}
