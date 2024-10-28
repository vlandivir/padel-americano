// ignore_for_file: avoid_print

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

  String formatTournamentInfo(Tournament tournament) {
    final buffer = StringBuffer();
    buffer.writeln('Points: ${tournament.numberOfPoints}');
    buffer.writeln('Courts: ${tournament.numberOfCourts}');
    buffer.writeln('Players:');
    for (var player in tournament.players) {
      buffer.writeln(' - ${player.name} (ID: ${player.id})');
    }

    if (tournament.drawPairs.isNotEmpty) {
      buffer.writeln('Draw pairs:');
      for (int i = 0; i <tournament.drawPairs.length; i += 1) {
        Team drawPair = tournament.drawPairs[i];
        buffer.writeln('${drawPair.player1.name} (${drawPair.player1.id}) & ${drawPair.player2.name} (${drawPair.player2.id})');

      }
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
      print('${entry.key.name} ${entry.value}');
    }
  }

  void printTeams(List<Team> teams, {String splitter = ""}) {
    print('--- ${teams.length} ---');
    for (var team in teams) {
      print('Team: ${team.player1.name} (${team.player1.id}) & ${team.player2.name} (${team.player2.id})');
    }
    if (splitter != "") {
      print(splitter);
    }
  }

  void sortTeamsByCommonPlayers(List<Team> pairs) {
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

      // If counts are equal, sort by minimal player ID
      int aMinId = a.player1.id < a.player2.id ? a.player1.id : a.player2.id;
      int bMinId = b.player1.id < b.player2.id ? b.player1.id : b.player2.id;
      int compareMinId = aMinId.compareTo(bMinId);
      if (compareMinId != 0) {
        return compareMinId;
      }

      // If minimal player IDs are also equal, sort by maximum player ID
      int aMaxId = a.player1.id > a.player2.id ? a.player1.id : a.player2.id;
      int bMaxId = b.player1.id > b.player2.id ? b.player1.id : b.player2.id;
      int compareMaxId = aMaxId.compareTo(bMaxId);
      if (compareMaxId != 0) {
        return compareMaxId;
      }
 
      return 0;
    });
  }

  void createSchedule() {
    if (players.length < 4) {
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

    List<Team> sortedTeams = [];
    // Map<Player, int> usedPlayers = {};

    int escape = 0;
    while(pairs.isNotEmpty && escape < 1000) {
      Team team = pairs.first;
      
      if (sortedTeams.isNotEmpty) {
        Team previousTeam = sortedTeams.last;
        for (int i = 0; i < pairs.length; i += 1) {
          Team currentTeam = pairs[i];
          if (
            previousTeam.player1.id == currentTeam.player1.id ||
            previousTeam.player1.id == currentTeam.player2.id ||
            previousTeam.player2.id == currentTeam.player1.id ||
            previousTeam.player2.id == currentTeam.player2.id
          ) {
            continue;
          }
          
          team = currentTeam;
          break;
        }
      }

      pairs.remove(team);
      sortedTeams.add(team);

      sortTeamsByCommonPlayers(pairs);
      escape += 1;
    }

    // printTeams(sortedTeams);
    // printTeams(pairs, splitter: "\n\n");

    List<Match> initialMatches = [];
    int currentCourt = 1;

    for (int i = 0; i < sortedTeams.length; i += 2) {
      
      if (i + 1 >= sortedTeams.length) {
        drawPairs.add(sortedTeams[i]);
        break;
      }

      initialMatches.add(Match(
        courtNumber: currentCourt,
        team1: sortedTeams[i + 0],
        team2: sortedTeams[i + 1],
      ));
      
      currentCourt += 1;
      if (currentCourt > numberOfCourts) {
        currentCourt = 1;
      } 
    }

    int matchesInRound = (players.length / 4).floor();
    int playersInRound = matchesInRound * 4;
    List<int> lastPlayers = [];

    List<Match> sortedMatches = [];
    // while(matches.isNotEmpty && escape < 1000) {
    //   Match currentMatch = matches.first;
    //   List<int> currentPlayers = [];

    //   for (int i = 0; i < matches.length; i += 1) {
    //     currentMatch = matches[i];
    //     currentPlayers = [];
    //     currentPlayers.add(currentMatch.team1.player1.id);
    //     currentPlayers.add(currentMatch.team1.player2.id);
    //     currentPlayers.add(currentMatch.team2.player1.id);
    //     currentPlayers.add(currentMatch.team2.player2.id);

    //     if (
    //       lastPlayers.contains(currentPlayers[0]) ||
    //       lastPlayers.contains(currentPlayers[1]) ||
    //       lastPlayers.contains(currentPlayers[2]) ||
    //       lastPlayers.contains(currentPlayers[3])
    //     ) {
    //       continue;
    //     }
        
    //     break;
    //   }

    //   sortedMatches.add(currentMatch);
    //   matches.remove(currentMatch);
    //   lastPlayers.addAll(currentPlayers);
    //   if (lastPlayers.length >= playersInRound) {
    //     lastPlayers = lastPlayers.sublist(4);
    //   }

    //   escape += 1;
    // }

    sortedMatches.addAll(initialMatches);

    List<List<int>> matches = [];
    for (int i = 0; i < initialMatches.length; i += 1) {
      Match m = initialMatches[i];
      List<int> players = [];
      players.add(m.team1.player1.id);
      players.add(m.team1.player2.id);
      players.add(m.team2.player1.id);
      players.add(m.team2.player2.id);
      matches.add(players);
    }
    print(matches);

    for (int i = 0; i < matches.length; i += 1) {
      List<int> m = matches[i];
      m.sort();
      print('${m.reduce((v, e) => v + e)}, $m');
    }

    // int currentRound = 1;

    // for (int i = 0; i < sortedMatches.length;) {
    //   List<Match> roundMatches = [];
    //   for (int j = 0; j < matchesInRound && i < sortedMatches.length; i += 1, j += 1) {
    //     roundMatches.add(sortedMatches[i]);
    //   }
    //   schedule.add(Round(roundNumber: currentRound, matches: roundMatches));
    //   currentRound += 1;
    // }  

    // print(formatTournamentInfo(this));  
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
