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
    List<Player> shuffledPlayers = List.from(players)..shuffle();
    int roundNumber = 1;

    while (shuffledPlayers.length >= 4) {
      List<Match> matches = [];

      for (int court = 1; court <= numberOfCourts; court++) {
        if (shuffledPlayers.length < 4) break;

        Player player1 = shuffledPlayers.removeAt(0);
        Player player2 = shuffledPlayers.removeAt(0);
        Player player3 = shuffledPlayers.removeAt(0);
        Player player4 = shuffledPlayers.removeAt(0);

        matches.add(Match(
          courtNumber: court,
          team1: Team(player1: player1, player2: player2),
          team2: Team(player1: player3, player2: player4),
        ));
      }

      schedule.add(Round(roundNumber: roundNumber, matches: matches));
      roundNumber++;
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
