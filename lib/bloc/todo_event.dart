import 'package:equatable/equatable.dart';
import 'package:todo_app_sqflite/todo_model.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  const LoadTodosEvent();
}

class AddTodoEvent extends TodoEvent {
  final String title;
  final String description;
  final String date;

  const AddTodoEvent({
    required this.title,
    required this.description,
    required this.date,
  });

  @override
  List<Object?> get props => [title, description, date];
}

class UpdateTodoEvent extends TodoEvent {
  final TodoModel todo;

  const UpdateTodoEvent({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final int id;

  const DeleteTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
