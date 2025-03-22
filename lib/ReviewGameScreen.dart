import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddGameScreen.dart';
import 'dart:convert';

class ReviewGameScreen extends StatefulWidget {
  @override
  _ReviewGameScreenState createState() => _ReviewGameScreenState();
}

class _ReviewGameScreenState extends State<ReviewGameScreen> {
  List<Map<String, dynamic>> savedGames = [];
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadSavedGames();
  }

  // Fetch all the saved games
  Future<void> _loadSavedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGameTitle = prefs.getString('savedGameTitle');
    final savedGameCode = prefs.getString('savedGameCode');
    final savedQuestionsString = prefs.getString('savedQuestions');

    if (savedGameTitle != null && savedGameCode != null && savedQuestionsString != null) {
      setState(() {
        savedGames = [
          {
            'title': savedGameTitle,
            'code': savedGameCode,
            'questions': List<Map<String, dynamic>>.from(jsonDecode(savedQuestionsString)) // Used GPT
          }
        ];
      });
    }
  }

  // Selects which game you want
  void _selectGame(Map<String, dynamic> game) {
    setState(() {
      questions = game['questions'];
    });
  }

  // Add a method to go back to the game list
  void _goBackToGameList() {
    setState(() {
      questions = []; // Reset the questions list to show the game list again
    });
  }

  Widget _buildGameList() {
    return ListView.builder(
      itemCount: savedGames.length,
      itemBuilder: (context, index) {
        final game = savedGames[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              backgroundColor: const Color(0xFFE6E6FA), // Light purple background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 5.0, // Elevation to create a button-like effect
            ),
            onPressed: () => _selectGame(game),
            child: Text(
              game['title'],
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black, // Black text color
              ),
            ),
          ),
        );
      },
    );
  }

  // Build the list of questions
  Widget _buildQuestionList() {
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        final options = question['options'];

        // If options is a string, split it by commas. If it's a list, use it as is.
        final optionsList = options is String ? options.split(',') : List<String>.from(options);

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${index + 1}: ${question['text']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Column(
                  children: optionsList.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: option == question['correct_answer'] ? Colors.green : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget to display the options and correct answer
  Widget optionTabs(List<String> options, String correctAnswer) {
    return Column(
      children: [
        const Text(
          'Options:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Column(
          children: options.map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: option == correctAnswer ? Colors.green : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Text(
          'Correct Answer: $correctAnswer',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Games'),
        backgroundColor: Colors.purple[200],
        leading: questions.isEmpty
            ? null // Don't show the back button if already in game list
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToGameList, // Go back to the game list
        ),
      ),
      backgroundColor: Colors.purple[100],
      body: questions.isEmpty
          ? _buildGameList() // Show list of games when no questions are selected
          : _buildQuestionList(), // Show questions when a game is selected
    );
  }
}
