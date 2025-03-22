import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'GameQuestionScreen.dart';

class HostedGameDetailsScreen extends StatefulWidget {
  final int gameId;
  final String gameTitle;
  final String gameCode;

  const HostedGameDetailsScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.gameCode,
  });

  @override
  _HostedGameDetailsScreenState createState() =>
      _HostedGameDetailsScreenState();
}

class _HostedGameDetailsScreenState extends State<HostedGameDetailsScreen> {
  late String gameCode;

  @override
  void initState() {
    super.initState();
    gameCode = widget.gameCode;
  }

  String _generateGameCode() {
    final random = Random();
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        6, (index) => characters[random.nextInt(characters.length)]).join();
  }

  Future<void> _updateGameCode() async {
    final dbHelper = DatabaseHelper();

    try {
      String updatedGameCode = _generateGameCode();
      await dbHelper.updateGame(widget.gameId, widget.gameTitle, updatedGameCode);

      setState(() {
        gameCode = updatedGameCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game code successfully updated.')),
      );
    } catch (e) {
      print("Error saving game: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save the game. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hosting Game: ${widget.gameTitle}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Join Code: ${gameCode}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameQuestionsScreen(
                      gameId: widget.gameId,
                      gameTitle: widget.gameTitle,
                      gameCode: gameCode,
                    ),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _updateGameCode,
              child: const Text('Regenerate Code'),
            ),
          ],
        ),
      ),
    );
  }
}
