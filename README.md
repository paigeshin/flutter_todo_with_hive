### Source

https://www.youtube.com/watch?v=FYfnQ55UPAo

### Add Dependency

```shell
flutter pub add hive
flutter pub add hive_flutter
flutter pub add -d hive_generator
flutter pub add -d build_runner
```

### Create Model

```dart
import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  bool finished;

  Task(
    this.title, {
    this.finished = false,
  });

}
```

```shell
flutter packages pub run build_runner build
```

### Initialize

```dart
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await HiveHelper().openBox();
  runApp(const MyApp());
}
```

### Helper

```dart
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
```

### Reorderable ListView

```dart
ReorderableListView(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    proxyDecorator:
        (Widget child, int index, Animation<double> animation) {
    return TaskTile(
        task: tasks[index],
        onDeleted: () {
            setState(() {});
        });
    },
    children: <Widget>[
    for (int index = 0; index < tasks.length; index += 1)
        Padding(
        key: Key('$index'),
        padding: const EdgeInsets.all(8.0),
        child: TaskTile(
            task: tasks[index],
            onDeleted: () {
            setState(() {
                tasks.removeAt(index);
            });
            },
        ),
        )
    ],
    onReorder: (int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
        newIndex -= 1;
    }
    await HiveHelper().reorder(oldIndex, newIndex);
    setState(() {});
    // setState(() {
    //   if (oldIndex < newIndex) {
    //     newIndex -= 1;
    //   }
    //   final Task item = tasks.removeAt(oldIndex);
    //   tasks.insert(newIndex, item);
    // });
    },
),
```

### Model Method

```dart
widget.task.finished = checked ?? false;
widget.task.save();
widget.task.delete();
```
