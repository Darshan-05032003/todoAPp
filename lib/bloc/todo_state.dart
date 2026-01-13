import 'package:equatable/equatable.dart';
import 'package:todo_app_sqflite/todo_model.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;

  const TodoLoaded({required this.todos});

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TodoSuccess extends TodoState {
  final String message;
  final List<TodoModel> todos;

  const TodoSuccess({
    required this.message,
    required this.todos,
  });

  @override
  List<Object?> get props => [message, todos];
}
