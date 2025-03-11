import 'package:flutter/material.dart';

Future<String?> showAddTaskDialog(BuildContext context) async {
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


Future<String?> showEditTaskDialog(BuildContext context, String currentTitle) async {
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
            onPressed: () => Navigator.pop(context), // ❌ Bekor qilish
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text), // ✅ Yangi nomni qaytarish
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

