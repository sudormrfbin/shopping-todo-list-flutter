import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shopping List',
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
        title: const Text('Shopping List'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: ((context, index) {
          final todo = _todos[index];
          return TodoItem(
            todo: todo,
            onButtonTap: _handleTodoDelete,
          );
        }),
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
      _todos.add(Todo(name: text, done: false));
    });
    _textController.clear();
  }

  void _handleTodoDelete(Todo todo) {
    setState(() => _todos.remove(todo));
  }
}

class Todo {
  final String name;
  bool done;

  Todo({required this.name, required this.done});
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(Todo) onButtonTap;

  const TodoItem({Key? key, required this.todo, required this.onButtonTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          todo.name,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => onButtonTap(todo),
        ));
  }
}
