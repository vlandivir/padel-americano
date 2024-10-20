import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'tournament.dart';

class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key});

  static const routeName = '/';

  @override
  _TournamentHomePageState createState() => _TournamentHomePageState();
}
class _TournamentHomePageState extends State<TournamentHomePage> {
  late Box<Tournament> tournamentBox;
  final TextEditingController _numberOfPlayersController = TextEditingController(text: '8');
  final TextEditingController _numberOfCourtsController = TextEditingController(text: '2');
  final TextEditingController _numberOfPointsController = TextEditingController(text: '16');

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
    for (int i = 1; i <= numberOfPlayers; i++) {
      tournament.addPlayer('Player $i', i);
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
                        final tournament = box.getAt(index);
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
    buffer.writeln('Schedule:');
    for (var round in tournament.schedule) {
      buffer.writeln(' Round ${round.roundNumber}:');
      for (var match in round.matches) {
        buffer.writeln('  Court ${match.courtNumber}: ${match.team1.player1.name} & ${match.team1.player2.name} vs ${match.team2.player1.name} & ${match.team2.player2.name}');
      }
    }
    return buffer.toString();
  }  
}
