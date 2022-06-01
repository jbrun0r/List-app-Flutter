import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:list_app/models/todo.dart';
import 'package:list_app/repositories/todo_repository.dart';
import 'package:list_app/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];

  Todo? deleteTodo;
  int? deleteTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Colors.black12,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xff08172E),
                Color(0xff2B3D5B),
                //Color(0xff08172E),
                //Color(0xff),
                //Color(0xff),
                //Color(0xff),
                //Color(0xff),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            color: Color(0xdad3d3d3),
                          ),
                          controller: todoController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adicione uma tarefa',
                            hintText: 'Ex. Comprar Bananas',
                            hintStyle: TextStyle(
                              color: Color(0xff5d6366),
                            ),
                            errorText: errorText,
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xbfcc0000),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xff5d6366),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xdad3d3d3),
                                width: 2,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: Color(0xdad3d3d3),
                            ),
                          ),
                          cursorColor: Color(0xdad3d3d3),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String text = todoController.text;

                          if (text.isEmpty) {
                            setState(() {
                              errorText = 'Digite o título da tarefa!';
                            });
                            return;
                          }
                          setState(() {
                            Todo newTodo = Todo(
                              title: text,
                              dateTime: DateTime.now(),
                            );
                            todos.add(newTodo);
                            errorText = null;
                          });
                          todoController.clear();
                          todoRepository.saveTodoList(todos);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff003553),
                          padding: EdgeInsets.all(18),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Color(0xFFd3d3d3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (Todo todo in todos)
                          TodoListItem(
                            todo: todo,
                            onDelete: onDelete,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Você possui ${todos.length} tarefas pendentes',
                          style: TextStyle(
                            color: Color(0xdad3d3d3),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: showDeleteTodosConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                            primary:  Color(0xbfcc0000),
                            padding: EdgeInsets.all(18)),
                        child: Text(
                          'Limpar tudo',
                          style: TextStyle(
                            color: Color(0xdad3d3d3),
                          ),
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
  }

  void onDelete(Todo todo) {
    deleteTodo = todo;
    deleteTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: TextStyle(
            color: Color(0xffd3d3d3),
          ),
        ),
        backgroundColor: const Color(0xff5d6366),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xff00264d),
          onPressed: () {
            setState(() {
              todos.insert(deleteTodoPos!, deleteTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffd3d3d3),
        title: Text(
          'Deseja Excluir?',
        ),
        content: Text('Você tem certeza que deseja apagar todas as tarefas? '),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Color(0xff00264d)),
            child: Text(
              'Cancelar',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(primary: Color(0xbfcc0000)),
            child: Text(
              'Limpar Tudo',
            ),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
