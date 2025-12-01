import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_flow/controllers/ToDoController.dart';
import 'package:task_flow/models/todo_model.dart';
import 'package:task_flow/views/HomePage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(ToDoModelAdapter());
  await Hive.openBox<ToDoModel>('toDos');

  tz.initializeTimeZones();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await notificationsPlugin.initialize(initSettings);

  // ---- REQUEST NOTIFICATION PERMISSION ----
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // ---- REQUEST EXACT ALARM PERMISSION ---
  if (Platform.isAndroid) {
    final androidPlugin = notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (Platform.isAndroid) {
  await Permission.scheduleExactAlarm.request();
}
  }

  Get.put(ToDoController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo & Reminder App',
      home: HomePage(),
    );
  }
}
