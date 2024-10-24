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
  final TextEditingController _numberOfPlayersController = TextEditingController(text: '9');
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
    final numberOfPlayers = int.tryParse(_numberOfPlayersController.text) ?? 9;
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
                          subtitle: Text(tournament.formatTournamentInfo(tournament)),
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
}
