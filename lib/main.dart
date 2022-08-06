import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Todo List',
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _textController = TextEditingController();
  final List<Todo> _todos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView(
        children: _todos
            .map((todo) => TodoItem(
                  todo: todo,
                  onTodoChanged: _handleTodoChange,
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add new todo'),
            content: TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: 'New todo'),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addTodoItem(_textController.text);
                  },
                  child: const Text('Add')),
            ],
          );
        });
  }

  void _addTodoItem(String text) {
    setState(() {
      _todos.add(Todo(name: text, checked: false));
    });
    _textController.clear();
  }

  void _handleTodoChange(Todo todo, bool newVal) {
    setState(() => todo.checked = newVal);
  }
}

class Todo {
  final String name;
  bool checked;

  Todo({required this.name, required this.checked});
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(Todo, bool) onTodoChanged;

  const TodoItem({Key? key, required this.todo, required this.onTodoChanged})
      : super(key: key);

  TextStyle? _getTextStyle() {
    if (!todo.checked) return null;

    return const TextStyle(color: Colors.black38, decoration: TextDecoration.lineThrough);
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        onChanged: (newVal) => onTodoChanged(todo, newVal ?? false),
        value: todo.checked,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(todo.name, style: _getTextStyle(),));
  }
}
