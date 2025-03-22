import 'package:projectest/PlayGame.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class JoinGamePlay extends StatefulWidget{
  String? gameCode;
  JoinGamePlay({super.key, required this.gameCode});
  @override
  _JoinGamePlay createState() => _JoinGamePlay();
}

class _JoinGamePlay extends State<JoinGamePlay> {
  late List<Map<String, dynamic>>  gamesByID = [];

  Future<List<Map<String, dynamic>>> _fetchGames() async {
    final dbHelper = DatabaseHelper();
    final allGames = await dbHelper.fetchGames();

    for (var game in allGames){
      if (widget.gameCode == game['code']){
        gamesByID.insert(0, game);
      }
    }
    return gamesByID;
  }

  void _StartGame(BuildContext context, Map<String,dynamic> game) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayGame(
          gameId: game['id'],
          gameTitle: game['title'],
          gameCode: game['code'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Game'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No games available to host.'));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return ListTile(
                  title: Text(game['title']),
                  subtitle: const Text('Tap to join the game'),
                  onTap: () => _StartGame(context, game), // Navigates to HostedGameDetailsScreen with code
                );
              },
            );
          }
        },
      ),
    );
  }
}
