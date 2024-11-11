// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_americano/src/users.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'tournament.dart';

class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key});

  static const routeName = '/';

  @override
  TournamentHomePageState createState() => TournamentHomePageState();
}

const defaultPlayersNumber = 12;
const defaultCourtsNumber = 2;
const defaultPointsNumber = 16;

class TournamentHomePageState extends State<TournamentHomePage> {
  final TextEditingController _numberOfPlayersController = TextEditingController(text: defaultPlayersNumber.toString());
  final TextEditingController _numberOfCourtsController = TextEditingController(text: defaultCourtsNumber.toString());
  final TextEditingController _numberOfPointsController = TextEditingController(text: defaultPointsNumber.toString());

  final List<String> playerNames = [
    'Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Hank', 'Ivy', 'Jack', 'Kathy', 'Leo', 'Mia', 
    'Nancy', 'Oscar', 'Paul', 'Quincy', 'Rachel', 'Steve', 'Tracy', 'Uma', 'Vince', 'Wendy', 'Xander', 'Yara', 'Zack'
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> createTournament() async {
    final numberOfPlayers = int.tryParse(_numberOfPlayersController.text) ?? defaultPlayersNumber;
    // final numberOfCourts = int.tryParse(_numberOfCourtsController.text) ?? defaultCourtsNumber;
    // final numberOfPoints = int.tryParse(_numberOfPointsController.text) ?? defaultPointsNumber;

    var users = await getUsers();
    var players = users.sublist(0, numberOfPlayers);

    createSchedule(players);
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
          ],
        ),
      ),
    );
  }
}
