import 'package:flutter/material.dart';
import 'database_helper.dart';

class QuestionEditor extends StatefulWidget {
  final int gameId;
  final Map<String, dynamic>? question; 
  final VoidCallback onSave;

  const QuestionEditor({
    required this.gameId,
    this.question,
    required this.onSave,
    super.key,
  });

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _optionsControllers = List.generate(4, (_) => TextEditingController()); // This was from GPT

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      
      _questionController.text = widget.question!['text'];
      _correctAnswerController.text = widget.question!['correct_answer'];
      final options = widget.question!['options'].split(',');
      for (int i = 0; i < options.length; i++) {
        if (i < _optionsControllers.length) {
          _optionsControllers[i].text = options[i];
        }
      }
    }
  }

  void _saveQuestion() async {
    final dbHelper = DatabaseHelper();
    final text = _questionController.text;
    final correctAnswer = _correctAnswerController.text;
    final options = _optionsControllers.map((controller) => controller.text).join(',');

    if (widget.question == null) {
     
      await dbHelper.insertQuestion(widget.gameId, text, options, correctAnswer);
    } else {
      
      await dbHelper.updateQuestion(widget.question!['id'], text, options, correctAnswer);
    }
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Add Question' : 'Edit Question'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _correctAnswerController,
              decoration: const InputDecoration(labelText: 'Correct Answer'),
            ),
            const SizedBox(height: 10),
            ..._optionsControllers.map(
              (controller) => TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Option'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveQuestion,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
