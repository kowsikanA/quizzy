import 'package:projectest/JoinGamePlay.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class JoinGameScreen extends StatelessWidget {
  String code = "9CR24M";
  final TextEditingController joinCodeController = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Game Code'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: joinCodeController,
              decoration: const InputDecoration(labelText: 'Join Code'),
            ),
           
            const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: () async{
              final dbHelper = DatabaseHelper();
              final codeEntered = joinCodeController.text;

              final gamesFetched = await dbHelper.fetchGames(); // Idea was given by GPT
              bool codeFound = false;

              for (var game in gamesFetched){
                print('$game');
                if ('${game['code']}' == codeEntered){
                  codeFound = true;
                  break;
                }
              } // Idea given by GPT

              if (codeFound){
                 Navigator.push(context,
                  MaterialPageRoute(
                  builder: (context) => 
                  JoinGamePlay(gameCode: codeEntered,)));
              } // Idea given by GPT

               else{
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect join code')),
                  );
               }
              },
            child: const Text('Join Game')
          ),
          ],
        ),
      ),
    );
  }
}
