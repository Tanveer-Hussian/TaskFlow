import 'package:get/get.dart';
import 'package:task_flow/models/todo_model.dart';

class ToDoController extends GetxController{

     Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
    
     void delete(ToDoModel toDosModel) async{
        await toDosModel.delete();
     }

 }
