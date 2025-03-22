import 'package:flutter/material.dart';
import 'AddGameScreen.dart';
import 'HostGameScreen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to AddGameScreen to create a new game
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGameScreen()),
                );
              },
              child: const Text('Create a Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => HostGameScreen())
                );
              },
              child: const Text('Host a Game'),
            ),
          ],
        ),
      ),
    );
  }
}
