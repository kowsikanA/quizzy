import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'QuestionEditor.dart';

class EditGameScreen extends StatefulWidget {
  final int gameId;
  final String gameTitle;
  final String gameCode;

  const EditGameScreen({
    super.key,
    required this.gameId,
    required this.gameTitle,
    required this.gameCode,
  });

  @override
  _EditGameScreenState createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final dbHelper = DatabaseHelper();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  late Future<List<Map<String, dynamic>>> questions;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.gameTitle;
    _codeController.text = widget.gameCode;
    questions = dbHelper.fetchQuestions(widget.gameId); // Fetch existing questions
  }

  void _saveGame() async {
    await dbHelper.updateGame(
      widget.gameId,
      _titleController.text,
      _codeController.text,
    );
    Navigator.pop(context); // Return to the previous screen
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionEditor(
        gameId: widget.gameId,
        onSave: () {
          setState(() {
            questions = dbHelper.fetchQuestions(widget.gameId); // Refresh questions
          });
        },
      ),
    );
  }

  void _editQuestion(Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder: (context) => QuestionEditor(
        gameId: widget.gameId,
        question: question,
        onSave: () {
          setState(() {
            questions = dbHelper.fetchQuestions(widget.gameId); // Refresh questions
          });
        },
      ),
    );
  }

  void _deleteQuestion(int questionId) async {
    await dbHelper.deleteQuestion(questionId);
    setState(() {
      questions = dbHelper.fetchQuestions(widget.gameId); // Refresh questions
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Game'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Game Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Game Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: questions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No questions found.'));
                  } else {
                    final questionList = snapshot.data!;
                    return ListView.builder(
                      itemCount: questionList.length,
                      itemBuilder: (context, index) {
                        final question = questionList[index];
                        return ListTile(
                          title: Text(question['text']),
                          subtitle: Text('Correct Answer: ${question['correct_answer']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editQuestion(question), // Edit question
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteQuestion(question['id']), // Delete question
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveGame,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}