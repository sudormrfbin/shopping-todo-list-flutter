import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingListApp());
}

class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shopping List',
      home: ShoppingItemList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShoppingItemList extends StatefulWidget {
  const ShoppingItemList({Key? key}) : super(key: key);

  @override
  State<ShoppingItemList> createState() => _ShoppingItemListState();
}

enum NewItemError {
  emptyInput,
  itemAlreadyExists,
}

class _ShoppingItemListState extends State<ShoppingItemList> {
  final _newItemTextController = TextEditingController();
  NewItemError? _newItemError;
  final List<ShoppingItem> _items = [];
  final List<int> _multiSelection = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          if (_multiSelection.isNotEmpty) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _multiSelection.reversed.forEach(_items.removeAt);
                  _multiSelection.clear();
                });
              },
              icon: const Icon(Icons.delete),
            )
          ]
        ],
      ),
      body: Builder(builder: (context) {
        if (_items.isEmpty) {
          return const Center(
            child: Text(
              "Add an item to your shopping list to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: _items.length,
            itemBuilder: ((context, index) {
              final item = _items[index];
              return ShoppingItemWidget(
                item: item,
                onButtonTap: _handleItemDelete,
                onLongPress: _handleItemSelect,
                onTap: _handleItemTap,
                selected: _multiSelection.contains(index),
                showDeleteIcon: _multiSelection.isEmpty,
              );
            }),
          );
        }
      }),
      floatingActionButton: _multiSelection.isEmpty
          ? FloatingActionButton(
              onPressed: () {
                _displayDialog().then((_) {
                  setState(() => _newItemTextController.text = "");
                  setState(() => _newItemError = null);
                });
              },
              tooltip: 'Add shopping item',
              child: const Icon(Icons.add),
            )
          : null,
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
                controller: _newItemTextController,
                decoration: InputDecoration(
                  hintText: 'New item',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      final text = _newItemTextController.text;
                      if (text.isEmpty) {
                        setState(() => _newItemError = NewItemError.emptyInput);
                        return;
                      }
                      if (_items.indexWhere((item) => item.name == text) !=
                          -1) {
                        setState(() =>
                            _newItemError = NewItemError.itemAlreadyExists);
                        return;
                      }

                      Navigator.of(context).pop();
                      _newItemError = null;
                      _addItem(_newItemTextController.text);
                    },
                    child: const Text('Add')),
              ],
            );
          });
        });
  }

  void _addItem(String text) {
    setState(() {
      _items.add(ShoppingItem(name: text, done: false));
    });
    _newItemTextController.clear();
  }

  void _handleItemDelete(ShoppingItem item) {
    setState(() => _items.remove(item));
  }

  _handleItemSelect(ShoppingItem todo) {
    final todoIndex = _items.indexOf(todo);
    final idx = _multiSelection.indexOf(todoIndex);
    if (idx != -1) {
      setState(() => _multiSelection.removeAt(idx));
      return;
    }

    int insertAt = _multiSelection.indexWhere((item) => todoIndex < item);
    if (insertAt == -1) {
      insertAt = 0;
    }
    setState(() => _multiSelection.insert(insertAt, todoIndex));
  }

  _handleItemTap(ShoppingItem item) {
    if (_multiSelection.isNotEmpty) {
      _handleItemSelect(item);
    }
  }
}

class ShoppingItem {
  final String name;
  bool done;

  ShoppingItem({required this.name, required this.done});
}

class ShoppingItemWidget extends StatelessWidget {
  final ShoppingItem item;
  final Function(ShoppingItem) onButtonTap;
  final Function(ShoppingItem) onLongPress;
  final Function(ShoppingItem) onTap;
  final bool selected;
  final bool showDeleteIcon;

  const ShoppingItemWidget({
    Key? key,
    required this.item,
    required this.onButtonTap,
    required this.onLongPress,
    required this.onTap,
    required this.selected,
    required this.showDeleteIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        item.name,
      ),
      trailing: showDeleteIcon
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onButtonTap(item),
            )
          : null,
      onLongPress: () => onLongPress(item),
      onTap: () => onTap(item),
      selected: selected,
      selectedTileColor: Theme.of(context).selectedRowColor,
    );
  }
}
