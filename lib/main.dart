import 'package:projectest/studentlogin.dart';
import 'package:projectest/teacherlogin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'default_channel_id',
    'default_channel_name',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformChannelSpecifics,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Welcome!'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  Widget _TextSlogan(String string) {
    return Text(
      string,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzy'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  _TextSlogan("Your Classroom"),
                  _TextSlogan("Your Game"),
                  _TextSlogan("Your Rules"),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Image.network(
                "https://i.imgur.com/rEAXs5k.png",
                errorBuilder: (context, error, stackTrace) {
                  return const Placeholder(
                    fallbackWidth: double.infinity,
                    fallbackHeight: 400,
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Log In As',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 15),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentLoginPage()),
                      );
                    },
                    child: const Text('Student'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeacherLoginPage()),
                      );
                    },
                    child: const Text('Teacher'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
