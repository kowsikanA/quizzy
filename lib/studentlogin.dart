import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectest/passwordstudent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projectest/StudentDashBoard.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Login Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StudentLoginPage(),
    );
  }
}

class StudentLoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<DocumentSnapshot?> getStudent(String username) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first;
    } catch (e) {
      print("Error getting student: $e");
      return null;
    }
  }

  Future<void> addStudent(String username, String password) async {
    try {
      await FirebaseFirestore.instance.collection('students').add({
        'username': username,
        'password': password,
      });

      // Show notification
      await showNotification(
        'Account Created',
        'Student account created successfully!',
      );
      print("Student added successfully!");
    } catch (e) {
      print("Error adding student: $e");
    }
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'student_account_creation_channel', // Updated channel ID for students
      'Student Account Notifications', // Updated channel name
      channelDescription:
          'Notification for successful student account creation',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
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

  void _showCreateAccountDialog(BuildContext context) {
    final TextEditingController newUsernameController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newUsernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await addStudent(
                    newUsernameController.text, newPasswordController.text);

                await showNotification(
                  'Account Created',
                  'Student account created successfully!',
                );
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget margin() {
    return SizedBox(
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple[200]),
      backgroundColor: Colors.purple[100],
      body:
          Center(
            child: Card(
              color: Colors.purple[50],
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Student Login',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      margin(),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                            labelText: 'Username', filled: true, fillColor: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                            labelText: 'Password', filled: true, fillColor: Colors.white),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      margin(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[300],
                                foregroundColor: Colors.white,
                                shadowColor: Colors.black,

                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 40
                                )
                                ),
                            onPressed: () async {
                              String username = usernameController.text;
                              String password = passwordController.text;

                              DocumentSnapshot? studentDoc =
                                  await getStudent(username);

                              if (studentDoc != null) {
                                String storedPassword = studentDoc['password'];

                                if (storedPassword == password) {
                                  // Student login successful
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StudentDashboard()),
                                  );
                                } else {
                                  // Incorrect password
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Incorrect password')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Student not found')),
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 10),

                          ElevatedButton(
                            onPressed: () => _showCreateAccountDialog(context),
                             style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white54,
                              shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(

                                    borderRadius: BorderRadius.circular(5)),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 20
                                )),
                            child: const Text('Create Account'),
                          ),
                          const SizedBox(height: 10),


                        ],
                      ),
                      const SizedBox(height: 10,),
                      TextButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordStudent()),
                            );
                          },
                          child: Text('Forgot Password?')),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
