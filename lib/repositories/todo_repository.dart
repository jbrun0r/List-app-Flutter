import 'dart:convert';
import 'package:list_app/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

const TodoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getTodoList() async {
    sharedPreferences= await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(TodoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

  void saveTodoList(List<Todo> todos){
    final String jsonString = json.encode(todos);
    sharedPreferences.setString('todo_list', jsonString);
  }

}