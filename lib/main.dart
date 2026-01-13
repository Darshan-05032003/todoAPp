import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_sqflite/todo_ui_screen.dart';
import 'package:todo_app_sqflite/bloc/todo_bloc.dart';
import 'package:todo_app_sqflite/bloc/todo_event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc()..add(const LoadTodosEvent()),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        home: const TodoUiScreen(),
      ),
    );
  }
}
