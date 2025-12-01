import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId:0)
class ToDoModel extends HiveObject{

   @HiveField(0)
   String title;

   @HiveField(1)
   String description; 
 
   @HiveField(2)
   DateTime? dueDate;

   @HiveField(3)
   bool isCompleted;

   ToDoModel({required this.title, required this.description, this.dueDate, required this.isCompleted});

 }
