import 'package:flutter/material.dart';
import 'package:solid/repositories/task_repositories.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = true;

  TaskProvider(this._repository) {
    loadTasks(); // 🔥 Constructorda ma'lumotni yuklab olamiz
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _repository.getTasks(); // Ma'lumotlarni yuklash
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final task = Task(id: DateTime.now().toString(), title: title);
    await _repository.addTask(task);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = Task(id: task.id, title: task.title, isCompleted: !task.isCompleted);
    await _repository.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    await loadTasks();
  }
  

  Future<void> editTask(Task task, String newTitle) async {
  final updatedTask = Task(id: task.id, title: newTitle, isCompleted: task.isCompleted);
  await _repository.updateTask(updatedTask);
  await loadTasks(); // 🔄 Yangilangan tasklarni qayta yuklash
}

}
