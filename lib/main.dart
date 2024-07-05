import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:achievement_app/models/achievement.dart';
import 'package:achievement_app/screens/achievement_list.dart'
as AchievementListScreen;
import 'package:achievement_app/screens/login_page.dart';
import 'package:achievement_app/screens/register_page.dart';
import 'package:achievement_app/screens/splashscreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialization for local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AchievementAdapter());
  await Hive.openBox<Achievement>('achievements');

  runApp(AchievementApp());
}

class AchievementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Growth',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreenPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => AchievementListScreen.AchievementList(),
      },
    );
  }
}
