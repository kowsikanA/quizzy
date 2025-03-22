import 'package:flutter/material.dart';
import 'database_helper.dart';

class GameQuestionsScreen extends StatefulWidget {
  final int gameId;
  final String gameTitle;
  final String gameCode;

  const GameQuestionsScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.gameCode,
  });

  @override
  _GameQuestionsScreenState createState() => _GameQuestionsScreenState();
}

class _GameQuestionsScreenState extends State<GameQuestionsScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> questions;

  @override
  void initState() {
    super.initState();
    questions = dbHelper.fetchQuestions(widget.gameId); // Fetch questions for the game
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Column(
        children: [
          const SizedBox(height: 10), // Spacing between the AppBar and the Join Code container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10), // Add horizontal margin
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.purple[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Code: ${widget.gameCode}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Share this code with students to join the game.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: questions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No questions available.'));
                } else {
                  final questionList = snapshot.data!;
                  return ListView.builder(
                    itemCount: questionList.length,
                    itemBuilder: (context, index) {
                      final question = questionList[index];
                      final options = question['options'].split(','); // Assuming options are comma-separated

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${index + 1}: ${question['text']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...options.map((option) => Text('- $option')),
                              const SizedBox(height: 15), // Spacing above the correct answer
                              Text(
                                'Correct Answer: ${question['correct_answer']}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
