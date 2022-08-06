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

enum NewItemError {
  emptyInput,
  itemAlreadyExists,
}

class _TodoListState extends State<TodoList> {
  final _textController = TextEditingController();
  NewItemError? _newItemError;
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
        onPressed: () {
          _displayDialog().then((_) {
            setState(() => _textController.text = "");
            setState(() => _newItemError = null);
          });
        },
        tooltip: 'Add shopping item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            String? errorText;
            switch (_newItemError) {
              case NewItemError.emptyInput:
                errorText = "Item name cannot be empty";
                break;
              case NewItemError.itemAlreadyExists:
                errorText = "Item already exists in list";
                break;
              case null:
                break;
            }

            return AlertDialog(
              title: const Text('Add new item'),
              content: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'New item',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      final text = _textController.text;
                      if (text.isEmpty) {
                        setState(() => _newItemError = NewItemError.emptyInput);
                        return;
                      }
                      if (_todos.indexWhere((todo) => todo.name == text) !=
                          -1) {
                        setState(() =>
                            _newItemError = NewItemError.itemAlreadyExists);
                        return;
                      }

                      Navigator.of(context).pop();
                      _newItemError = null;
                      _addTodoItem(_textController.text);
                    },
                    child: const Text('Add')),
              ],
            );
          });
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
