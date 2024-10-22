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

  @HiveField(5)
  List<Team> drawPairs = [];

  Tournament({required this.name, required this.numberOfPoints, required this.numberOfCourts});

  void addPlayer(String playerName, int playerId) {
    players.add(Player(name: playerName, id: playerId));
  }

  Map<Player, int> countPlayers(List<Team> pairs) {
    Map<Player, int> playerCounts = {};

    // Count how many times each player appears in the list of pairs
    for (Team team in pairs) {
      playerCounts.update(team.player1, (count) => count + 1, ifAbsent: () => 1);
      playerCounts.update(team.player2, (count) => count + 1, ifAbsent: () => 1);
    }

    return playerCounts;
  }

  int getMaxPlayerCount (List<Team> pairs) {
    Map<Player, int> playerCounts = countPlayers(pairs);
    int max = 0;
    for(var count in playerCounts.values) {
      if (max < count) {
        max = count; 
      }
    }

    return max;
  } 

  void printCounts(Map<Player, int> playerCounts) {
    for(var entry in playerCounts.entries) {
      // ignore: avoid_print
      print('${entry.key.name} ${entry.value}');
    }
  }

  void printTeams(List<Team> teams, {String splitter = ""}) {
    // ignore: avoid_print
    print('--- ${teams.length} ---');
    for (var team in teams) {
      // ignore: avoid_print
      print('Team: ${team.player1.name} & ${team.player2.name}');
    }
    if (splitter != "") {
      // ignore: avoid_print
      print(splitter);
    }
  }

  void sortTeamsByCommonPlayers(List<Team> pairs, int count) {
    // Create a map to count the occurrences of each player
    Map<Player, int> playerCounts = countPlayers(pairs);

    // Count how many times each player appears in the list of pairs
    for (Team team in pairs) {
      playerCounts.update(team.player1, (count) => count + 1, ifAbsent: () => 1);
      playerCounts.update(team.player2, (count) => count + 1, ifAbsent: () => 1);
    }

    // Sort pairs based on the max count of their players, then by min count,
    // then by minimal player ID, and finally by maximum player ID
    pairs.sort((a, b) {
      int aMaxCount = playerCounts[a.player1]! > playerCounts[a.player2]! ? playerCounts[a.player1]! : playerCounts[a.player2]!;
      int aMinCount = playerCounts[a.player1]! < playerCounts[a.player2]! ? playerCounts[a.player1]! : playerCounts[a.player2]!;
      int bMaxCount = playerCounts[b.player1]! > playerCounts[b.player2]! ? playerCounts[b.player1]! : playerCounts[b.player2]!;
      int bMinCount = playerCounts[b.player1]! < playerCounts[b.player2]! ? playerCounts[b.player1]! : playerCounts[b.player2]!;

      // First, compare by max count in descending order
      int compareMaxCount = bMaxCount.compareTo(aMaxCount);
      if (compareMaxCount != 0) {
        return compareMaxCount;
      }

      // If max counts are equal, compare by min count in descending order
      int compareMinCount = bMinCount.compareTo(aMinCount);
      if (compareMinCount != 0) {
        return compareMinCount;
      }

      // int compareSum = (bMaxCount + bMinCount).compareTo(aMaxCount + aMinCount);
      // if (compareSum != 0) {
      //   return compareSum;
      // }

      // If counts are equal, sort by minimal player ID
      int aMinId = a.player1.id < a.player2.id ? a.player1.id : a.player2.id;
      int bMinId = b.player1.id < b.player2.id ? b.player1.id : b.player2.id;
      int compareMinId = aMinId.compareTo(bMinId);
      if (compareMinId != 0) {
        return compareMinId;
      }

      // If minimal player IDs are also equal, sort by maximum player ID
      // int aMaxId = a.player1.id > a.player2.id ? a.player1.id : a.player2.id;
      // int bMaxId = b.player1.id > b.player2.id ? b.player1.id : b.player2.id;
      // int compareMaxId = aMaxId.compareTo(bMaxId);
      // if (compareMaxId != 0) {
      //   return compareMaxId;
      // }
 
      return 0;
    });
  }

  void createSchedule() {
    if (players.length < 4) {
      // ignore: avoid_print
      print('Not enough players to create a schedule. At least 4 players are required.');
      return;
    }

    schedule.clear();

    // players.shuffle();

    // Create all possible pairs from players
    List<Team> pairs = [];
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        pairs.add(Team(player1: players[i], player2: players[j]));
      }
    }

    int matchesInRound = (players.length / 4).floor();
    int pairsInRound = matchesInRound * 2;
    int roundsNumber = (pairs.length / 2 / matchesInRound).floor();

    int currentCourt = 1;

    List<Team> filtered = [];

    int escapeCount = 0;
    sortTeamsByCommonPlayers(pairs, players.length);

    for (int i = 0; i < roundsNumber; i += 1) {
      List<Match> matches = [];
      List<Team> teams = [];

      int shift = 0;
  
      while(teams.length < pairsInRound && pairs.isNotEmpty) {
        Team currentTeam = pairs[0];
        teams.add(currentTeam);
        pairs.remove(currentTeam);
        
        for(int j = pairs.length - 1; j > -1; j -= 1) {
          Team currentPair = pairs[j];
          if (
            currentPair.player1 == currentTeam.player1 || 
            currentPair.player1 == currentTeam.player2 ||
            currentPair.player2 == currentTeam.player1 || 
            currentPair.player2 == currentTeam.player2
          ) {
            filtered.add(currentPair);
            pairs.remove(currentPair);
          }
        }


        bool notEnoughTeams = pairs.isEmpty && teams.length < pairsInRound;
        bool brokenLastRound = pairs.isEmpty && filtered.length <= pairsInRound && getMaxPlayerCount(filtered) > 1;

        if (notEnoughTeams || brokenLastRound) {
          // print('notEnoughTeams: $notEnoughTeams')
          escapeCount++;

          if (escapeCount > 999) {
            break;
          }

          List<Team> tmp = [];

          tmp.addAll(filtered);
          tmp.addAll(teams);
          sortTeamsByCommonPlayers(tmp, players.length);

          shift += 1;

          // if (shift >= tmp.length) {
          //   tmp.shuffle();
          //   shift = 0;
          // } 

          pairs.addAll(tmp.sublist(shift));
          pairs.addAll(tmp.sublist(0, shift));

          filtered = [];
          teams = [];
        }
      }

      pairs.addAll(filtered);
      filtered = [];

      sortTeamsByCommonPlayers(pairs, players.length);
      // ignore: avoid_print
      print('Round: ${i + 1}. Escape count: $escapeCount');
      printTeams(teams);
      printTeams(pairs, splitter: '\n\n');

      // if (pairs.isNotEmpty && pairs.length + teams.length < pairsInRound * 2 - 1) {
      //   // ignore: avoid_print
      //   print("Can't create schedule");
      //   break;
      // }

      // if (teams.length < pairsInRound) {
      //   // Didn't find enought teams for round. Trying to resort
      //   filtered.addAll(teams);
      //   i -= 1;
      //   continue;
      // }

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

    if (pairs.isNotEmpty) {
      drawPairs.addAll(pairs);
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
