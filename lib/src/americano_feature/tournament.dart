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

  void printTeams(List<Team> teams) {
    // ignore: avoid_print
    print('--- ${teams.length} ---');
    for (var team in teams) {
      // ignore: avoid_print
      print('Team: ${team.player1.name} & ${team.player2.name}');
    }
  }

  void createSchedule() {
    if (players.length < 4) {
      // ignore: avoid_print
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
    // pairs.shuffle();

    int matchesInRound = (players.length / 4).floor();
    int pairsInRound = matchesInRound * 2;
    int roundsNumber = (pairs.length / 2 / matchesInRound).floor();

    int currentCourt = 1;

    List<Player> usedPlayers;

    for (int i = 0; i < roundsNumber; i += 1) {
      List<Match> matches = [];
      List<Team> teams = [];
      usedPlayers = [];

      // Select teams for round
      for (int j = 0; j < pairs.length; j += 1) {
        Team currentTeam = pairs[j];
        if (!usedPlayers.contains(currentTeam.player1) && !usedPlayers.contains(currentTeam.player2)) {
          teams.add(currentTeam);
          pairs.remove(currentTeam);
          j -= 1;
          usedPlayers.add(currentTeam.player1);
          usedPlayers.add(currentTeam.player2);
        }

        if (teams.length == pairsInRound) {
          break;
        }
      }

      printTeams(teams);
      printTeams(pairs);

      // Create matches for selected teams
      for (int j = 0; j < teams.length; j += 2) {
        matches.add(Match(
          courtNumber: currentCourt,
          team1: teams[j + 0],
          team2: teams[j + 1],
        ));

        currentCourt += 1;
        if (currentCourt > numberOfCourts) {
          currentCourt = 1;
        } 
      }

      // Create round
      if (matches.isNotEmpty) {
        schedule.add(Round(roundNumber: i + 1, matches: matches));
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
