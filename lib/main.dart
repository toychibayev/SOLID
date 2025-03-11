import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solid/repositories/task_repositories.dart';
import 'providers/task_provider.dart';
import 'screens/task_screen.dart';

void main() {
  final taskRepository = LocalTaskRepository(); // 🔥 LocalTaskRepository dan foydalanamiz

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider(taskRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskScreen(), // 🔥 Asosiy ekran
    );
  }
}
