import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_sqflite/database.dart';
import 'package:todo_app_sqflite/todo_model.dart';
import 'package:todo_app_sqflite/bloc/todo_event.dart';
import 'package:todo_app_sqflite/bloc/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoDatabase _database = TodoDatabase();

  TodoBloc() : super(const TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(const TodoLoading());
      List<Map> cardList = await _database.getTodoItems();
      log("CARD LIST: $cardList");
      
      List<TodoModel> todos = [];
      for (var element in cardList) {
        todos.add(
          TodoModel(
            date: element['date'],
            description: element['description'],
            title: element['title'],
            id: element['id'],
          ),
        );
      }
      
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: 'Failed to load todos: $e'));
    }
  }

  Future<void> _onAddTodo(
    AddTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(const TodoLoading());
      
      Map<String, dynamic> dataMap = {
        'title': event.title,
        'date': event.date,
        'description': event.description,
      };
      
      await _database.insertTodoItem(dataMap);
      
      // Reload todos
      List<Map> cardList = await _database.getTodoItems();
      List<TodoModel> todos = [];
      for (var element in cardList) {
        todos.add(
          TodoModel(
            date: element['date'],
            description: element['description'],
            title: element['title'],
            id: element['id'],
          ),
        );
      }
      
      emit(TodoSuccess(
        message: 'Todo added successfully!',
        todos: todos,
      ));
    } catch (e) {
      emit(TodoError(message: 'Failed to add todo: $e'));
    }
  }

  Future<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(const TodoLoading());
      
      Map<String, dynamic> mapObj = {
        'title': event.todo.title,
        'description': event.todo.description,
        'date': event.todo.date,
        'id': event.todo.id,
      };
      
      await _database.updateTodoItem(mapObj);
      
      // Reload todos
      List<Map> cardList = await _database.getTodoItems();
      List<TodoModel> todos = [];
      for (var element in cardList) {
        todos.add(
          TodoModel(
            date: element['date'],
            description: element['description'],
            title: element['title'],
            id: element['id'],
          ),
        );
      }
      
      emit(TodoSuccess(
        message: 'Todo updated successfully!',
        todos: todos,
      ));
    } catch (e) {
      emit(TodoError(message: 'Failed to update todo: $e'));
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(const TodoLoading());
      
      await _database.deleteTodoItem(event.id);
      
      // Reload todos
      List<Map> cardList = await _database.getTodoItems();
      List<TodoModel> todos = [];
      for (var element in cardList) {
        todos.add(
          TodoModel(
            date: element['date'],
            description: element['description'],
            title: element['title'],
            id: element['id'],
          ),
        );
      }
      
      emit(TodoSuccess(
        message: 'Todo deleted successfully!',
        todos: todos,
      ));
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todo: $e'));
    }
  }
}
