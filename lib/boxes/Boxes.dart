import 'package:hive/hive.dart';
import 'package:task_flow/models/todo_model.dart';

class Boxes {

   static Box<ToDoModel> getData() => Hive.box<ToDoModel>('toDos');

 }
 