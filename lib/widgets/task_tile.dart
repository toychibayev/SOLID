import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solid/widgets/dialogs.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

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
  if (direction == DismissDirection.endToStart) {
    final newTitle = await showEditTaskDialog(context, task.title);
    if (newTitle != null && newTitle.isNotEmpty) {
      await taskProvider.editTask(task, newTitle); // 🔥 await qo‘shildi
      return false; // 🔄 Elementni o‘chirish emas, faqat yangilash
    }
  } else if (direction == DismissDirection.startToEnd) {
    await taskProvider.deleteTask(task.id);
    return true; // 🗑 O‘chirish
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
          onChanged: (_) => taskProvider.toggleTaskCompletion(task),
        ),
      ),
    );
  }
}
