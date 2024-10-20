import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'tournament.dart';

class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key});

  static const routeName = '/';

  @override
  TournamentHomePageState createState() => TournamentHomePageState();
}
class TournamentHomePageState extends State<TournamentHomePage> {
  late Box<Tournament> tournamentBox;
  final TextEditingController _numberOfPlayersController = TextEditingController(text: '8');
  final TextEditingController _numberOfCourtsController = TextEditingController(text: '2');
  final TextEditingController _numberOfPointsController = TextEditingController(text: '16');

  final List<String> playerNames = [
    'Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Hank', 'Ivy', 'Jack', 'Kathy', 'Leo', 'Mia', 'Nancy', 'Oscar', 'Paul', 'Quincy', 'Rachel', 'Steve', 'Tracy', 'Uma', 'Vince', 'Wendy', 'Xander', 'Yara', 'Zack'
  ];

  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future<void> openBox() async {
    tournamentBox = await Hive.openBox<Tournament>('tournamentBox');
    setState(() {});
  }

  void createTournament() {
    final numberOfPlayers = int.tryParse(_numberOfPlayersController.text) ?? 8;
    final numberOfCourts = int.tryParse(_numberOfCourtsController.text) ?? 2;
    final numberOfPoints = int.tryParse(_numberOfPointsController.text) ?? 16;

    final tournament = Tournament(name: 'Americano Padel', numberOfPoints: numberOfPoints, numberOfCourts: numberOfCourts);
    for (int i = 0; i < numberOfPlayers && i < playerNames.length; i++) {
      tournament.addPlayer(playerNames[i], i + 1);
    }
    tournament.createSchedule();
    tournamentBox.add(tournament);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    TextField(
                      controller: _numberOfPlayersController,
                      decoration: InputDecoration(
                        labelText: 'Number of Players',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _numberOfCourtsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Courts',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _numberOfPointsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Points',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: createTournament,
                      child: Text('Create Tournament'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Tournament>('tournamentBox').listenable(),
                builder: (context, Box<Tournament> box, _) {
                  if (box.values.isEmpty) {
                    return Center(child: Text('No Tournaments Created'));
                  }
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: ListView.builder(
                      itemCount: box.values.length,
                      itemBuilder: (context, index) {
                        final tournament = box.getAt(box.values.length - 1 - index); // sort
                        if (tournament == null) {
                          return ListTile(
                            title: Text('Unnamed Tournament'),
                            subtitle: Text('No information available'),
                          );
                        }
                        return ListTile(
                          title: Text(tournament.name),
                          subtitle: Text(_formatTournamentInfo(tournament)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTournamentInfo(Tournament tournament) {
    final buffer = StringBuffer();
    buffer.writeln('Points: ${tournament.numberOfPoints}');
    buffer.writeln('Courts: ${tournament.numberOfCourts}');
    buffer.writeln('Players:');
    for (var player in tournament.players) {
      buffer.writeln(' - ${player.name} (ID: ${player.id})');
    }
    if (tournament.drawPair.isNotEmpty) {
      Team drawPair = tournament.drawPair[0];
      buffer.writeln('Draw pair: ${drawPair.player1.name} (${drawPair.player1.id}) & ${drawPair.player2.name} (${drawPair.player2.id})');
    }
    buffer.writeln('Schedule:');
    for (var round in tournament.schedule) {
      buffer.writeln(' Round ${round.roundNumber}:');
      for (var match in round.matches) {
        final team1 = '${match.team1.player1.name} (${match.team1.player1.id}) & ${match.team1.player2.name} (${match.team1.player2.id})';
        final team2 = '${match.team2.player1.name} (${match.team2.player1.id}) & ${match.team2.player2.name} (${match.team2.player2.id})';
        buffer.writeln('  Court ${match.courtNumber}: $team1 vs $team2');
      }
    }
    return buffer.toString();
  }  
}
