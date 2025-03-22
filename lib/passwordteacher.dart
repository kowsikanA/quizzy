import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  
import 'firebase_options.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Password Reset',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ForgotPasswordTeacher(),
    );
  }
}

class ForgotPasswordTeacher extends StatelessWidget {
  final TextEditingController teacherUserNameController = TextEditingController();
  final TextEditingController authCodeController = TextEditingController();
  final TextEditingController newPassWordController = TextEditingController();

  // Method to get teacher by username
  Future<DocumentSnapshot?> getTeacher(String username) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;  // Teacher not found
      }

      return querySnapshot.docs.first;  // Teacher document found
    } catch (e) {
      print("Error getting teacher: $e");
      return null;
    }
  }

  // Method to update teacher password by username
  Future<void> updatePasswordByUsername(String username, String newPassword) async {
    try {
      // Fetch the teacher document
      DocumentSnapshot? teacherDoc = await getTeacher(username);

      if (teacherDoc != null) {
        // If the teacher exists, update the password
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(teacherDoc.id) // Use the document ID to update the document
            .update({
              'password': newPassword, // Update the password field
            });
        print("Password updated successfully!");
      } else {
        print("Teacher not found");
      }
    } catch (e) {
      print("Error updating password: $e");
    }
  }

  // Function to show feedback after updating the password
  void showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Password Reset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: teacherUserNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: authCodeController,
              decoration: InputDecoration(labelText: 'Enter Authentication Code'),
              obscureText: true,
            ),
            TextField(
              controller: newPassWordController,
              decoration: InputDecoration(labelText: 'Enter New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = teacherUserNameController.text;
                String authCode = authCodeController.text;
                String newPassword = newPassWordController.text;

                // Check if the authentication code is correct
                if (authCode == '123') {
                  // If the code is correct, proceed with updating the password
                  await updatePasswordByUsername(username, newPassword);

                  // Show feedback to user
                  showFeedback(context, 'Password updated successfully!');
                  
                  // Show notification
                  await flutterLocalNotificationsPlugin.show(
                    0, 
                    'Password Reset', 
                    'Your password has been successfully updated!', 
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        'teacher_channel_id', 
                        'Teacher Notifications',
                        importance: Importance.high,
                        priority: Priority.high,
                        ticker: 'ticker',
                      ),
                    ),
                  );
                } else {
                  // If the code is incorrect, show an error message
                  showFeedback(context, 'Incorrect authentication code.');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
