import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'Pages/HomePage.dart';
import 'Pages/ProfilePage.dart';
import 'Pages/Achievements.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("hell yeah");
    print("Workmanager task executed: $task");
    await checkQuitDateAndNotify();
    print("Workmanager task finished");
    return Future.value(true);
  });
}

Future<void> checkQuitDateAndNotify() async {
  final Box<dynamic> box = Hive.box('cigarette_tracker');
  DateTime? quitDate = box.get('_quitdate') as DateTime?;
  List<dynamic> unlockedAchievements = box.get('unlockedAchievements', defaultValue: []) as List<dynamic>;

  if (quitDate != null) {
    DateTime currentDate = DateTime.now();
    int minutesSinceQuit = currentDate.difference(quitDate).inMinutes;

    print("Minutes since quit date: $minutesSinceQuit");
    print("Unlocked achievements: $unlockedAchievements");

    if (minutesSinceQuit > unlockedAchievements.length) {
      unlockedAchievements.add(minutesSinceQuit);
      box.put('unlockedAchievements', unlockedAchievements);

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'Notification channel for quit date reminder',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: null,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Achievement Unlocked',
        'You have unlocked a new health benefit!',
        notificationDetails,
        payload: 'Achievement unlocked',
      );

      print("Notification sent!");
    }
  } else {
    print("Quit date is null");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('cigarette_tracker');  // Open (and create if not exists) a Hive box named 'cigarette_tracker'

  final Box<dynamic> box = Hive.box('cigarette_tracker');
  DateTime? quitDate = box.get('_quitdate') as DateTime?;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize timezone data
  tz.initializeTimeZones();

  // Ensure that the notification channel is created
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // id
    'your_channel_name', // title
    description: 'Notification channel for quit date reminder',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  print("1");
  // Initialize Workmanager and register the periodic task
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    'checkQuitDateTask',
    'checkQuitDateTask',
    frequency: Duration(minutes: 15),  // Increase frequency for testing
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
  print("2");

  runApp(MyApp(initialRoute: quitDate == null ? '/profile' : '/'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cigarette Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: initialRoute,  // Set initial route based on quitDate
      routes: {
        '/': (context) => Home(),  // HomePage as the home page
        '/profile': (context) => ProfilePage(),  // ProfilePage for first-time setup
        '/achievements': (context) => Achievements(),
      },
    );
  }
}
