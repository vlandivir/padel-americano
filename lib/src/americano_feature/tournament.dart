import 'package:hive/hive.dart';

part 'tournament.g.dart';

@HiveType(typeId: 0)
class Tournament extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int numberOfPoints;

  @HiveField(2)
  int numberOfCourts;

  @HiveField(3)
  List<Player> players = [];

  @HiveField(4)
  List<Round> schedule = [];

  Tournament({required this.name, required this.numberOfPoints, required this.numberOfCourts});

  void addPlayer(String playerName, int playerId) {
    players.add(Player(name: playerName, id: playerId));
  }

  void createSchedule() {
    if (players.length < 4) {
      print('Not enough players to create a schedule. At least 4 players are required.');
      return;
    }

    schedule.clear();

    // Create all possible pairs from players
    List<Team> pairs = [];
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        pairs.add(Team(player1: players[i], player2: players[j]));
      }
    }

    // Shuffle the pairs
    pairs.shuffle();

    int roundNumber = 1;
    List<Player> usedPlayers;

    // Create rounds
    while (pairs.length >= 2) {
      List<Match> matches = [];
      usedPlayers = [];
      int matchesInRound = (players.length / 4).floor();

      for (int i = 0; i < matchesInRound; i++) {
        if (pairs.isEmpty) break;

        Team team1;
        Team team2;

        // Find a valid pair for team1
        team1 = pairs.firstWhere((pair) =>
            !usedPlayers.contains(pair.player1) && !usedPlayers.contains(pair.player2),
            orElse: () => Team(player1: Player(name: '', id: -1), player2: Player(name: '', id: -1)));
        if (team1.player1.id == -1) break;

        // Remove the used pair and add players to used list
        pairs.remove(team1);
        usedPlayers.add(team1.player1);
        usedPlayers.add(team1.player2);

        // Find a valid pair for team2
        team2 = pairs.firstWhere((pair) =>
            !usedPlayers.contains(pair.player1) && !usedPlayers.contains(pair.player2),
            orElse: () => Team(player1: Player(name: '', id: -1), player2: Player(name: '', id: -1)));
        if (team2.player1.id == -1) break;

        // Remove the used pair and add players to used list
        pairs.remove(team2);
        usedPlayers.add(team2.player1);
        usedPlayers.add(team2.player2);

        // Add match to the round
        matches.add(Match(
          courtNumber: 0, // No court information needed
          team1: team1,
          team2: team2,
        ));
      }

      if (matches.isNotEmpty) {
        schedule.add(Round(roundNumber: roundNumber, matches: matches));
        roundNumber++;
      } else {
        break;
      }
    }
  }
}

@HiveType(typeId: 1)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int id;

  Player({required this.name, required this.id});
}

@HiveType(typeId: 2)
class Team extends HiveObject {
  @HiveField(0)
  Player player1;

  @HiveField(1)
  Player player2;

  @HiveField(2)
  int score = 0;

  Team({required this.player1, required this.player2});
}

@HiveType(typeId: 3)
class Match extends HiveObject {
  @HiveField(0)
  int courtNumber;

  @HiveField(1)
  Team team1;

  @HiveField(2)
  Team team2;

  Match({required this.courtNumber, required this.team1, required this.team2});
}

@HiveType(typeId: 4)
class Round extends HiveObject {
  @HiveField(0)
  int roundNumber;

  @HiveField(1)
  List<Match> matches;

  Round({required this.roundNumber, required this.matches});
}
