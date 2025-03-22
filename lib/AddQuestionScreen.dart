import 'package:flutter/material.dart';
import 'AddGameScreen.dart';

class AddQuestionScreen extends StatefulWidget {
  final Function(Question) onQuestionAdded;

  const AddQuestionScreen({super.key, required this.onQuestionAdded});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _questionController = TextEditingController();
  final List<String> _options = List.filled(4, '');
  String? _correctAnswer;

  void _submitQuestion() {
    // Check for empty fields or unselected correct answer
    if (_correctAnswer == null ||
        _questionController.text.isEmpty ||
        _options.any((option) => option.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and select the correct answer.')),
      );
      return;
    }

    // Check for duplicate options
    final uniqueOptions = _options.toSet();
    if (uniqueOptions.length != _options.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Options must be unique. Please remove duplicates.')),
      );
      return;
    }

    // Create a new question object
    final question = Question(
      text: _questionController.text,
      options: _options,
      correctAnswer: _correctAnswer!,
    );

    // Pass the question to the parent widget
    widget.onQuestionAdded(question);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      resizeToAvoidBottomInset: true, // Ensures the UI adjusts for the keyboard
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question Text'),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < _options.length; i++)
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _options[i] = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _correctAnswer,
                hint: const Text('Select Correct Answer'),
                items: _options
                    .toSet() // Remove duplicates
                    .where((option) => option.isNotEmpty)
                    .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _correctAnswer = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  labelText: 'Explanation (Description)',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitQuestion,
                child: const Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}