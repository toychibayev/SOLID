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

abstract class TaskFilter {
  List<Task> filter(List<Task> tasks);
}

class CompletedTaskFilter implements TaskFilter {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted).toList();
  }
}

class PendingTaskFilter implements TaskFilter {
  @override
  List<Task> filter(List<Task> tasks) {
    return tasks.where((task) => !task.isCompleted).toList();
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
  TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: ListView.builder(
        itemCount: taskController.getTasks().length,
        itemBuilder: (context, index) {
          final task = taskController.getTasks()[index];
          return Dismissible(
            key: Key(task.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              taskController.deleteTask(task.id);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
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
}
