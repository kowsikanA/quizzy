import 'package:projectest/StudentDashBoard.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'dart:ui';
import 'dart:convert';

class PlayGame extends StatefulWidget {
  final int gameId;
  final String gameTitle;
  final String gameCode;

  const PlayGame({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.gameCode,
  });

  @override
  _PlayGameState createState() => _PlayGameState();
}

class _PlayGameState extends State<PlayGame> {
  bool match = false;
  String feedbackMessage = '';
  int currentIndex = 0;
  int correctAnswers = 0;  // Track the correct answers
  late List<Map<String, dynamic>> questions = [];
  PageController currentQuestionController = PageController();
  bool showScorePopup = false;  // Show score popup when game finishes

  @override
  void initState() {
    super.initState();
    _saveGameCode(widget.gameCode, widget.gameTitle);
    _fetchAndSaveQuestions();
  }

  // Fetch the questions from the database
  Future<List<Map<String, dynamic>>> _fetchQuestions() async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> questions = await dbHelper.fetchQuestions(widget.gameId); // Used GPT
    return questions;
  }

  Future<void> _saveGameCode(String code, String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedGameCode', code);
    await prefs.setString('savedGameTitle', title); // Store game title
  }

  Future<void> _fetchAndSaveQuestions() async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> questions = await dbHelper.fetchQuestions(widget.gameId); // Used GPT

    // Save questions to SharedPreferences as a JSON string
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedQuestions', jsonEncode(questions));

    setState(() {
      this.questions = questions;
    });
  }

  // Show feedback message
  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Handle next question logic
  void _nextQuestion(int totalQuestions) {
    if (currentIndex < totalQuestions - 1) {
      setState(() {
        currentIndex++; // Move to the next question
        feedbackMessage = ''; // Reset the feedback message
      });
      // Use a delay to allow the feedback to show first, before navigating to the next question
      Future.delayed(const Duration(milliseconds: 300), () {
        currentQuestionController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Game Finished, show score popup
      setState(() {
        showScorePopup = true;
      });
    }
  }

  // Option button that checks if the answer is correct and shows feedback
  Widget optionButton(String option, String correctAnswer, int totalQuestions) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (option == correctAnswer) {
            match = true;
            feedbackMessage = 'Correct';
            correctAnswers++;  // Increment score for correct answer
          } else {
            match = false;
            feedbackMessage = 'Incorrect';
          }
        });
        _showFeedback(feedbackMessage);
        _nextQuestion(totalQuestions);
      },
      child: Text(option),
    );
  }

  // Layout of the options in a grid
  Widget optionTabs(List<String> options, String correctAnswer, int totalQuestions) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            optionButton(options[0], correctAnswer, totalQuestions),
            optionButton(options[2], correctAnswer, totalQuestions),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            optionButton(options[1], correctAnswer, totalQuestions),
            optionButton(options[3], correctAnswer, totalQuestions),
          ],
        ),
      ],
    );
  }

  // Show the score popup with background blur
  Widget _scorePopup() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Over',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You answered $correctAnswers out of ${questions.length} correctly!',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StudentDashboard()),
                      );
                    },
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameTitle), backgroundColor: Colors.purple[200],),
      backgroundColor: Colors.purple[100],
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(  // Building the game question list
                    future: _fetchQuestions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No questions found for this game.'));
                      } else {
                        questions = snapshot.data!; // Update the questions list
                        return PageView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: currentQuestionController,
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final question = questions[index];
                            final options = question['options'].split(','); // Assuming options are comma-separated

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Q${index + 1}: ${question['text']}',
                                        style: const TextStyle(
                                            fontSize: 25, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 50),
                                      optionTabs(options, question['correct_answer'], questions.length),
                                      const SizedBox(height: 10),
                                      if (feedbackMessage.isNotEmpty)
                                        ElevatedButton(
                                          onPressed: () => _nextQuestion(questions.length),
                                          child: Text(
                                            index == questions.length - 1 ? 'Finish' : 'Next',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Container(
                  height: 200,
                ),
              ],
            ),
          ),
          if (showScorePopup) _scorePopup(),  // Show score popup when game is finished
        ],
      ),
    );
  }
}
