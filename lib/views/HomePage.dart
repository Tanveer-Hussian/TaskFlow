import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_flow/boxes/Boxes.dart';
import 'package:task_flow/controllers/ToDoController.dart';
import 'package:task_flow/models/todo_model.dart';
import 'package:task_flow/service/notification_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  final toDoController = Get.find<ToDoController>();
  final dueDateController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  HomePage({super.key});

  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    dueDateController.clear();
    toDoController.selectedDate.value = null;
  }

  void setEditValues(ToDoModel toDosModel) {
    titleController.text = toDosModel.title.toString();
    descriptionController.text = toDosModel.description;

    final d = toDosModel.dueDate;
    if (d != null) {
      dueDateController.text = DateFormat('dd-MM-yyyy HH:mm').format(d);
      toDoController.selectedDate.value = d;
    }
  }

  String formatDateTimeForField(DateTime dt) {
    return DateFormat('dd-MM-yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Flow',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ValueListenableBuilder<Box<ToDoModel>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<ToDoModel>();
          data = data.reversed.toList();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: ListView.builder(
              itemCount: box.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = data[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Slidable(
                    key: ValueKey(item.key),
                    endActionPane: ActionPane(motion: DrawerMotion(), children: [
                      SlidableAction(
                        icon: Icons.edit,
                        onPressed: (context) {
                          setEditValues(item);
                          _editDialog(item, context);
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        icon: Icons.delete,
                        onPressed: (context) async {
                          final key = item.key;
                          toDoController.delete(item);
                          // cancel scheduled notification for deleted task
                          if (key is int) {
                             await NotificationService.cancelNotification(key);
                          }
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: 'Delete',
                      )
                    ]),
                    child: Card(
                      color: Colors.blueGrey[500],
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                                Checkbox(
                                  value: item.isCompleted,
                                  onChanged: (bool? value) {
                                    item.isCompleted = value!;
                                    item.save();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              item.description.toString(),
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white),
                            ),
                            if (item.dueDate != null) ...[
                              SizedBox(height: 8),
                              Text(
                                'Reminder: ${formatDateTimeForField(item.dueDate!)}',
                                style: TextStyle(fontSize: 13, color: Colors.white70),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          clearFields();
          _showAddDialog(context);
        },
        shape: CircleBorder(),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
  
    );
  }


  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Due date + time field with two pickers (date & time)
                TextFormField(
                  controller: dueDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pick due date & time',
                    border: OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final today = DateTime.now();
                            final dueDate = await showDatePicker(
                              context: context,
                              initialDate: today,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2050),
                            );
                            if (dueDate != null) {
                              
                              final existing = toDoController.selectedDate.value;
                              final hour = existing?.hour ?? today.hour;
                              final minute = existing?.minute ?? today.minute;
                              final combined = DateTime(
                                  dueDate.year, dueDate.month, dueDate.day, hour, minute);
                              toDoController.selectedDate.value = combined;
                              dueDateController.text = formatDateTimeForField(combined);
                            }
                          },
                          icon: Icon(Icons.date_range),
                        ),
                        IconButton(
                          onPressed: () async {
                            final nowTime = TimeOfDay.now();
                            final picked =
                                await showTimePicker(context: context, initialTime: nowTime);
                            if (picked != null) {
                              final existing = toDoController.selectedDate.value ?? DateTime.now();
                              final combined = DateTime(existing.year, existing.month,
                                  existing.day, picked.hour, picked.minute);
                              toDoController.selectedDate.value = combined;
                              dueDateController.text = formatDateTimeForField(combined);
                            }
                          },
                          icon: Icon(Icons.access_time),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Add Title', border: OutlineInputBorder()),
                ),
                SizedBox(height: 14),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                      InputDecoration(hintText: 'Add Description', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                // validation
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    toDoController.selectedDate.value == null) {
                  Navigator.pop(context);
                  Get.snackbar('Could not add task', 'Kindly enter required fields (including date & time)');
                } else {
                  final scheduled = toDoController.selectedDate.value!;
                  if (!scheduled.isAfter(DateTime.now())) {
                    // Do not schedule notifications in past
                    Navigator.pop(context);
                    Get.snackbar('Invalid time', 'Please choose a future date & time for reminder');
                    return;
                  }

                  final data = ToDoModel(
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: scheduled,
                      isCompleted: false);
                  final box = Boxes.getData();

                  int key = await box.add(data);

                  // schedule notification (cancels previous if any with same id)
                  await NotificationService.scheduleNotification(
                    key,
                    data.title,
                    data.description,
                    data.dueDate!,
                  );

                  clearFields();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _editDialog(ToDoModel todosModel, BuildContext context) async {
    // setEditValues already called before opening dialog (so controllers and selectedDate are set)
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: dueDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pick due date & time',
                    border: OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final today = DateTime.now();
                            final dueDate = await showDatePicker(
                              context: context,
                              initialDate: toDoController.selectedDate.value ?? today,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2050),
                            );
                            if (dueDate != null) {
                              final existing = toDoController.selectedDate.value;
                              final hour = existing?.hour ?? today.hour;
                              final minute = existing?.minute ?? today.minute;
                              final combined = DateTime(
                                  dueDate.year, dueDate.month, dueDate.day, hour, minute);
                              toDoController.selectedDate.value = combined;
                              dueDateController.text = formatDateTimeForField(combined);
                            }
                          },
                          icon: Icon(Icons.date_range),
                        ),
                        IconButton(
                          onPressed: () async {
                            final nowTime = TimeOfDay.now();
                            final picked =
                                await showTimePicker(context: context, initialTime: nowTime);
                            if (picked != null) {
                              final existing = toDoController.selectedDate.value ?? DateTime.now();
                              final combined = DateTime(existing.year, existing.month,
                                  existing.day, picked.hour, picked.minute);
                              toDoController.selectedDate.value = combined;
                              dueDateController.text = formatDateTimeForField(combined);
                            }
                          },
                          icon: Icon(Icons.access_time),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Enter title', border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                      InputDecoration(hintText: 'Enter description', border: OutlineInputBorder()),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                // Update model fields
                todosModel.title = titleController.text.toString();
                todosModel.description = descriptionController.text.toString();
                todosModel.dueDate = toDoController.selectedDate.value;

                // Validate scheduled time
                if (todosModel.dueDate != null && !todosModel.dueDate!.isAfter(DateTime.now())) {
                  Navigator.pop(context);
                  Get.snackbar('Invalid time', 'Please choose a future date & time for reminder');
                  return;
                }

                await todosModel.save();

                if (todosModel.dueDate != null) {
                  await NotificationService.scheduleNotification(
                    todosModel.key,
                    todosModel.title,
                    todosModel.description,
                    todosModel.dueDate!,
                  );
                } else {
                  // If user cleared due date (not likely here) cancel notification
                  await NotificationService.cancelNotification(todosModel.key);
                }

                clearFields();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


}

