import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_sqflite/todo_model.dart';
import 'package:todo_app_sqflite/bloc/todo_bloc.dart';
import 'package:todo_app_sqflite/bloc/todo_event.dart';
import 'package:todo_app_sqflite/bloc/todo_state.dart';

class TodoUiScreen extends StatefulWidget {
  const TodoUiScreen({super.key});

  @override
  State<TodoUiScreen> createState() => _TodoUiScreenState();
}

class _TodoUiScreenState extends State<TodoUiScreen> {
  //CONTROLLERS
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;
  bool isFormExpanded = false;

  List<List<Color>> gradientColors = [
    [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple gradient
    [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink gradient
    [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue gradient
    [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green gradient
    [const Color(0xFFfa709a), const Color(0xFFfee140)], // Orange gradient
    [const Color(0xFF30cfd0), const Color(0xFF330867)], // Teal gradient
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void clearController() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    selectedDate = null;
    setState(() {
      isFormExpanded = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void submit(bool doEdit, [TodoModel? obj]) {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        (selectedDate != null || dateController.text.isNotEmpty)) {
      String dateString = selectedDate != null
          ? _formatDate(selectedDate!)
          : dateController.text;

      if (doEdit) {
        obj!.title = titleController.text;
        obj.description = descriptionController.text;
        obj.date = dateString;
        context.read<TodoBloc>().add(UpdateTodoEvent(todo: obj));
      } else {
        context.read<TodoBloc>().add(
              AddTodoEvent(
                title: titleController.text,
                description: descriptionController.text,
                date: dateString,
              ),
            );
      }
      clearController();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.red ? Icons.delete_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoSuccess) {
          _showSnackBar(
            state.message,
            state.message.contains('deleted')
                ? Colors.red
                : state.message.contains('updated')
                    ? Colors.blue
                    : Colors.green,
          );
        } else if (state is TodoError) {
          _showSnackBar(state.message, Colors.red);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.task_alt, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Todos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[500]!,
                  Colors.purple[400]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple[300]!,
                    Colors.blue[300]!,
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading && state is! TodoLoaded) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<TodoModel> todos = [];
            if (state is TodoLoaded) {
              todos = state.todos;
            } else if (state is TodoSuccess) {
              todos = state.todos;
            }

            return Column(
              children: [
                // Collapsible Input Form
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(16),
                  padding: EdgeInsets.all(isFormExpanded ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue[50]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isFormExpanded = !isFormExpanded;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue[400]!, Colors.purple[400]!],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add_task,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Add New Todo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedRotation(
                              turns: isFormExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: isFormExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(height: 0),
                        secondChild: Column(
                          children: [
                            const SizedBox(height: 20),
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                hintText: 'Enter todo title',
                                prefixIcon: const Icon(Icons.title, color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'Enter todo description',
                                prefixIcon: const Icon(Icons.description, color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedDate != null
                                            ? _formatDate(selectedDate!)
                                            : dateController.text.isEmpty
                                                ? 'Select Date'
                                                : dateController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selectedDate != null || dateController.text.isNotEmpty
                                              ? Colors.black87
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue[600]!, Colors.purple[500]!],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => submit(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add Todo',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Todo List Header
                if (todos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.purple[400]!],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${todos.length} ${todos.length == 1 ? 'Todo' : 'Todos'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                // Todo List
                Expanded(
                  child: todos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: const EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.task_alt,
                                        size: 80,
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No todos yet!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the form above to add your first todo',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            TodoModel todo = todos[index];
                            List<Color> cardGradient = gradientColors[index % gradientColors.length];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 300 + (index * 50)),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardGradient[0].withValues(alpha: 0.3),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            cardGradient[0].withValues(alpha: 0.1),
                                            cardGradient[1].withValues(alpha: 0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: cardGradient,
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  todo.title,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[900],
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  todo.description,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[700],
                                                    height: 1.4,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 14),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: cardGradient[0].withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        size: 16,
                                                        color: cardGradient[0],
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        todo.date,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: cardGradient[0],
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue[400]!,
                                                      Colors.blue[600]!,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blue.withValues(alpha: 0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit, size: 20),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    titleController.text = todo.title;
                                                    descriptionController.text = todo.description;
                                                    dateController.text = todo.date;
                                                    selectedDate = _parseDate(todo.date);
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => StatefulBuilder(
                                                        builder: (context, setDialogState) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            title: const Row(
                                                              children: [
                                                                Icon(Icons.edit, color: Colors.blue),
                                                                SizedBox(width: 8),
                                                                Text('Edit Todo'),
                                                              ],
                                                            ),
                                                            content: SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  TextField(
                                                                    controller: titleController,
                                                                    decoration: InputDecoration(
                                                                      labelText: 'Title',
                                                                      prefixIcon: const Icon(Icons.title),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                      filled: true,
                                                                      fillColor: Colors.grey[50],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 16),
                                                                  TextField(
                                                                    controller: descriptionController,
                                                                    decoration: InputDecoration(
                                                                      labelText: 'Description',
                                                                      prefixIcon: const Icon(Icons.description),
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                      filled: true,
                                                                      fillColor: Colors.grey[50],
                                                                    ),
                                                                    maxLines: 3,
                                                                  ),
                                                                  const SizedBox(height: 16),
                                                                  InkWell(
                                                                    onTap: () async {
                                                                      final DateTime? picked = await showDatePicker(
                                                                        context: context,
                                                                        initialDate: selectedDate ?? DateTime.now(),
                                                                        firstDate: DateTime(2000),
                                                                        lastDate: DateTime(2100),
                                                                      );
                                                                      if (picked != null) {
                                                                        setDialogState(() {
                                                                          selectedDate = picked;
                                                                          dateController.text = _formatDate(picked);
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(
                                                                          horizontal: 12, vertical: 16),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.grey[50],
                                                                        borderRadius: BorderRadius.circular(12),
                                                                        border: Border.all(color: Colors.grey[300]!),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          const Icon(Icons.calendar_today, color: Colors.blue),
                                                                          const SizedBox(width: 12),
                                                                          Expanded(
                                                                            child: Text(
                                                                              selectedDate != null
                                                                                  ? _formatDate(selectedDate!)
                                                                                  : dateController.text.isEmpty
                                                                                      ? 'Select Date'
                                                                                      : dateController.text,
                                                                              style: TextStyle(
                                                                                color: selectedDate != null || dateController.text.isNotEmpty
                                                                                    ? Colors.black87
                                                                                    : Colors.grey[600],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  clearController();
                                                                },
                                                                child: const Text('Cancel'),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  submit(true, todo);
                                                                  Navigator.pop(context);
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.blue[600],
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                child: const Text('Update'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red[400]!,
                                                      Colors.red[600]!,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.red.withValues(alpha: 0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete, size: 20),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    context.read<TodoBloc>().add(DeleteTodoEvent(id: todo.id));
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
