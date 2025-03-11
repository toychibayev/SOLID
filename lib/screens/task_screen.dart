import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/dialogs.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔄 Loading animatsiyasi
          : taskProvider.tasks.isEmpty
              ? const Center(child: Text("Hozircha vazifalar yo'q"))
              : ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return TaskTile(task: task);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await showAddTaskDialog(context);
          if (title != null && title.isNotEmpty) {
            await taskProvider.addTask(title);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
