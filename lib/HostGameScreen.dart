import 'package:projectest/EditGameScreen.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:projectest/HostedGameDetailScreen.dart';

class HostGameScreen extends StatefulWidget {
  @override
  _HostGameScreenState createState() => _HostGameScreenState();
}

class _HostGameScreenState extends State<HostGameScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> games;

  @override
  void initState() {
    super.initState();
    _refreshGames(); // Fetch games on initialization
  }

  void _refreshGames() {
    setState(() {
      games = dbHelper.fetchGames(); // Refresh the list of games
    });
  }

  void _deleteGame(int gameId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text('Are you sure you want to delete this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await dbHelper.deleteGame(gameId);
      _refreshGames(); // Refresh the game list after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host a Game'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.purple[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No games available.'));
          } else {
            final gameList = snapshot.data!;
            return ListView.builder(
              itemCount: gameList.length,
              itemBuilder: (context, index) {
                final game = gameList[index];
                return
                Card(
                  color: Colors.purple[50],
                child: ListTile(
                  title: Text(game['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  subtitle: Text('Game Code: ${game['code']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditGameScreen(
                                gameId: game['id'],
                                gameTitle: game['title'],
                                gameCode: game['code'],
                              ),
                            ),
                          ).then((_) => _refreshGames()); // Refresh after editing
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGame(game['id']),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HostedGameDetailsScreen(
                          gameId: game['id'],
                          gameTitle: game['title'],
                          gameCode: game['code'],
                        ),
                      ),
                    ).then((_) =>_refreshGames());
                  },
                )
                );
              },
            );
          }
        },
      ),
    );
  }
}