import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'AddQuestionScreen.dart';
import 'HostGameScreen.dart';
import 'dart:math';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  _AddGameScreenState createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  late HostGameScreen hostGameScreen;
  final _gameTitleController = TextEditingController();
  final List<Question> _questions = [];

  void _addQuestion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          onQuestionAdded: (question) {
            setState(() {
              _questions.add(question);
            });
          },
        ),
      ),
    );
  }

  String _generateGameCode() {
    final random = Random();
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        6, (index) => characters[random.nextInt(characters.length)]).join();
  }

  Future<void> _saveGame() async {
    if (_gameTitleController.text.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a game title and add at least one question.')),
      );
      return;
    }
    final dbHelper = DatabaseHelper();

    try {
      await dbHelper.insertGame(
        _gameTitleController.text,
        _generateGameCode(),
        _questions.map((question) {
          return {
            'text': question.text,
            'options': question.options.join(','), // Store options as comma-separated string
            'correctAnswer': question.correctAnswer,
          };
        }).toList(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error saving game: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save the game. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Game'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _gameTitleController,
              decoration: const InputDecoration(labelText: 'Game Title'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_questions[index].text),
                    subtitle: Text('Answer: ${_questions[index].correctAnswer}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveGame,
              child: const Text('Save Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String ?explanation; 

  Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });
}
