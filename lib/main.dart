import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

void main() {
  GetIt.I.registerLazySingleton<TaskRepository>(() => LocalTaskRepository());
  runApp(const MyApp());
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({required this.id, required this.title, this.isCompleted = false});
}

abstract class TaskRepository {
  List<Task> getTasks();
  void addTask(Task task);
  void updateTask(Task task);
  void deleteTask(String id);
}

class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  List<Task> getTasks() => _tasks;

  @override
  void addTask(Task task) {
    _tasks.add(task);
  }

  @override
  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
  }
}

class TaskController with ChangeNotifier {
  final TaskRepository _repository;

  TaskController(this._repository);

  List<Task> getTasks() => _repository.getTasks();

  void addTask(String title) {
    final task = Task(id: DateTime.now().toString(), title: title);
    _repository.addTask(task);
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    final updatedTask = Task(id: task.id, title: task.title, isCompleted: !task.isCompleted);
    _repository.updateTask(updatedTask);
    notifyListeners();
  }

  void deleteTask(String id) {
    _repository.deleteTask(id);
    notifyListeners();
  }

  void editTask(Task task, String newTitle) {
    final updatedTask = Task(id: task.id, title: newTitle, isCompleted: task.isCompleted);
    _repository.updateTask(updatedTask);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskController(GetIt.I<TaskRepository>()),
      child: MaterialApp(
        title: 'To-Do App',
        home: TaskScreen(),
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('To-Do List')),
          body: ListView.builder(
            itemCount: taskController.getTasks().length,
            itemBuilder: (context, index) {
              final task = taskController.getTasks()[index];
              return Dismissible(
                key: Key(task.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    taskController.deleteTask(task.id);
                    return true;
                  } else if (direction == DismissDirection.endToStart) {
                    final newTitle = await _showEditTaskDialog(context, task.title);
                    if (newTitle != null && newTitle.isNotEmpty) {
                      taskController.editTask(task, newTitle);
                    }
                    return false;
                  }
                  return false;
                },
                child: ListTile(
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ),
                  trailing: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => taskController.toggleTaskCompletion(task),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final title = await _showAddTaskDialog(context);
              if (title != null && title.isNotEmpty) {
                taskController.addTask(title);
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<String?> _showAddTaskDialog(BuildContext context) async {
    String taskTitle = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            onChanged: (value) {
              taskTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, taskTitle),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showEditTaskDialog(BuildContext context, String currentTitle) async {
    TextEditingController controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Edit task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
