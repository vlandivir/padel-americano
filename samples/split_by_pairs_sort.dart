// ignore_for_file: avoid_print, dead_code

import 'dart:math';

bool checkTournamentScheduleByChatGPT(List<List<List<int>>> schedule) {
  // Total number of players
  int numPlayers = schedule.expand((roundPairs) => roundPairs).expand((pair) => pair).reduce((a, b) => a > b ? a : b);

  // To track the pairs of players
  Set<String> playedPairs = {};
  List<int> playerMatchCount = List.filled(numPlayers + 1, 0);

  // Checking each round
  for (int roundIdx = 0; roundIdx < schedule.length; roundIdx++) {
    List<List<int>> roundPairs = schedule[roundIdx];
    Set<int> playersInRound = {};
    for (List<int> pair in roundPairs) {
      int player1 = pair[0];
      int player2 = pair[1];

      // Check if player1 or player2 already played in this round
      if (playersInRound.contains(player1) || playersInRound.contains(player2)) {
        print("Player ${playersInRound.contains(player1) ? player1 : player2} plays more than once in round ${roundIdx + 1}");
        return false;
      }

      playersInRound.addAll(pair);

      // Check if this pair of players has already played together
      String sortedPair = '${player1 < player2 ? player1 : player2}-${player1 < player2 ? player2 : player1}';
      if (playedPairs.contains(sortedPair)) {
        print("Players $player1 and $player2 play more than once in round ${roundIdx + 1}");
        return false;
      }
      playedPairs.add(sortedPair);

      // Increment match count for both players
      playerMatchCount[player1]++;
      playerMatchCount[player2]++;
    }
  }

  // Check if all players played the same number of matches
  int expectedMatchCount = playerMatchCount[1];
  for (int i = 1; i < playerMatchCount.length; i++) {
    if (playerMatchCount[i] != expectedMatchCount) {
      print("Player $i played ${playerMatchCount[i]} matches, while others played $expectedMatchCount");
      return false;
    }
  }

  print("Tournament schedule is valid");
  return true;
}

void printPairsByRounds(List<List<int>> pairs, int pairsPerRound) {
  for (int i = 0; i < pairs.length; i += pairsPerRound) {
    print(pairs.sublist(i, min(i + pairsPerRound, pairs.length)));
  }
}

List<List<List<int>>> splitByRounds(List<List<int>> pairs, int pairsPerRound) {
  List<List<List<int>>> result = [];
  for (int i = 0; i < pairs.length; i += pairsPerRound) {
    result.add(pairs.sublist(i, min(i + pairsPerRound, pairs.length)));
  }
  return result;
}

int sortPlayers (int players, List<List<int>> possiblePairs, {bool printLog = false}) {
  int matchesPerRound = players ~/ 4;
  int pairsPerRound = matchesPerRound * 2; 

  // possiblePairs.shuffle();

  int escape = 0, pointer = 0;
  List<int> playersInRound = [];

  for (; pointer < possiblePairs.length && escape++ < possiblePairs.length + 1; /* increment inside the loop */) {
    if (pointer % pairsPerRound == 0) {
      // new round
      playersInRound = [];
      // var unsortedPart = possiblePairs.sublist(pointer);
      // possiblePairs = possiblePairs.sublist(0, pointer);
      // possiblePairs.addAll(unsortedPart.reversed); 
    }
    var currentPair = possiblePairs[pointer];
    var player1 = currentPair[0];
    var player2 = currentPair[1];

    // Already have one of the players in the round
    if (playersInRound.contains(player1) || playersInRound.contains(player2)) {
      possiblePairs.remove(currentPair);
      possiblePairs.add(currentPair); // move current pair to the end
      continue;
    }

    playersInRound.add(player1);
    playersInRound.add(player2);
    escape = pointer;
    pointer += 1;
  }

  if (printLog) {
    print({'escape:', escape, 'pointer:', pointer, '?', pointer == possiblePairs.length});
  }
  return pointer;
}

List<List<List<int>>> generateSchedule(int players) {
  print('\n\n\n$players players');
  int matchesPerRound = players ~/ 4;
  int pairsPerRound = matchesPerRound * 2;

  // Create a list of all possible pairs
  List<List<int>> possiblePairs = [];
  for (int i = 1; i <= players; i++) {
    for (int j = i + 1; j <= players; j++) {
      possiblePairs.add([i, j]);
    }
  }

  bool playersShuffleRule = players == 12 || players > 16;
  // bool playersShuffleRule = true;

  if (playersShuffleRule) {
    possiblePairs.shuffle();
  }

  for (int j = 0; j < 19999999; j += 1) {
    var shuffleCondition = j % (possiblePairs.length * 2) == 0;
    var pointer = sortPlayers(players, possiblePairs, printLog: shuffleCondition);
    var scheduled = pointer == possiblePairs.length;

    if (scheduled) {
      print('\n$players players are scheduled on step $j');
      printPairsByRounds(possiblePairs, pairsPerRound);
      break;
    }
    
    if (playersShuffleRule) {
      if (shuffleCondition) {
        possiblePairs.shuffle();
      } else {
        var sortedPointer = max(
          0, 
          min(
            pointer ~/ pairsPerRound * pairsPerRound, 
            possiblePairs.length - pairsPerRound * pairsPerRound
          )
        );
        var unsortedPairs = possiblePairs.sublist(sortedPointer);        
        unsortedPairs.shuffle();
        var sortedPairs = possiblePairs.sublist(0, sortedPointer);

        possiblePairs = [];
        possiblePairs.addAll(sortedPairs);
        possiblePairs.addAll(unsortedPairs);
      }
    } else {
      possiblePairs = possiblePairs.reversed.toList();
    }
  }    

  return splitByRounds(possiblePairs, pairsPerRound);
}

void main(List<String> args) {
  int left = 25;
  int right = 31;

  left = right = 15;
  
  for (int players = left; players <= right; players += 1) {
    var schedule = generateSchedule(players);
    print('\n');
    checkTournamentScheduleByChatGPT(schedule);

    print('\n\n');
    List<List<int>> matrix = List.generate(players, (_) => List.generate(players, (_) => 0));


    for (int r = 0; r < schedule.length; r += 1) {
      List<List<int>> sortedRound = [];
      
      var round = schedule[r];
      print (schedule[r]);
      while(round.isNotEmpty) {
        var pair = round[0];
        round.removeAt(0);

        if (round.isEmpty) {
          sortedRound.add(pair);
          break;
        }

        int enemyIdx = 0;
        int enemyMin = players;
        for (int j = 0; j < round.length; j += 1) {
          var enemyPair = round[j];
          int enemyCnt = 0;
          enemyCnt += matrix[pair[0] - 1][enemyPair[0] - 1] + matrix[pair[0] - 1][enemyPair[1] - 1];
          enemyCnt += matrix[pair[1] - 1][enemyPair[0] - 1] + matrix[pair[1] - 1][enemyPair[1] - 1];
          if (enemyCnt < enemyMin) {
            enemyIdx = j;
          }
        }
        sortedRound.add(pair);
        sortedRound.add(round[enemyIdx]);
        round.removeAt(enemyIdx);
      }

      schedule[r] = sortedRound;

      for (int i = 0; i < sortedRound.length - 1; i += 2) {
        var fstTeam = sortedRound[i + 0];  
        var sndTeam = sortedRound[i + 1];

        matrix[fstTeam[0] - 1][sndTeam[0] - 1] += 1;
        matrix[fstTeam[0] - 1][sndTeam[1] - 1] += 1;
        matrix[fstTeam[1] - 1][sndTeam[0] - 1] += 1;
        matrix[fstTeam[1] - 1][sndTeam[1] - 1] += 1;

        matrix[sndTeam[0] - 1][fstTeam[0] - 1] += 1;
        matrix[sndTeam[0] - 1][fstTeam[1] - 1] += 1;
        matrix[sndTeam[1] - 1][fstTeam[0] - 1] += 1;
        matrix[sndTeam[1] - 1][fstTeam[1] - 1] += 1;
      }

      print (schedule[r]);
    }

    // Print the matrix
    for (var row in matrix) {
      print(row);
    }      
    print('\n\n');
  }  
}

/*
[0, 2, 1, 2, 0, 3, 2, 2, 3, 2, 3, 3, 1, 3, 1]
[2, 0, 2, 1, 0, 1, 4, 3, 6, 1, 2, 2, 1, 2, 1]
[1, 2, 0, 2, 3, 3, 2, 1, 1, 3, 2, 4, 1, 0, 1]
[2, 1, 2, 0, 4, 2, 4, 3, 2, 2, 0, 1, 3, 2, 0]
[0, 0, 3, 4, 0, 1, 2, 1, 3, 3, 2, 2, 1, 2, 4]
[3, 1, 3, 2, 1, 0, 1, 0, 1, 1, 1, 1, 1, 3, 7]
[2, 4, 2, 4, 2, 1, 0, 6, 1, 2, 0, 2, 1, 0, 1]
[2, 3, 1, 3, 1, 0, 6, 0, 0, 1, 1, 3, 3, 3, 1]
[3, 6, 1, 2, 3, 1, 1, 0, 0, 1, 2, 0, 3, 3, 2]
[2, 1, 3, 2, 3, 1, 2, 1, 1, 0, 7, 1, 2, 1, 1]
[3, 2, 2, 0, 2, 1, 0, 1, 2, 7, 0, 3, 2, 1, 2]
[3, 2, 4, 1, 2, 1, 2, 3, 0, 1, 3, 0, 2, 3, 1]
[1, 1, 1, 3, 1, 1, 1, 3, 3, 2, 2, 2, 0, 3, 4]
[3, 2, 0, 2, 2, 3, 0, 3, 3, 1, 1, 3, 3, 0, 2]
[1, 1, 1, 0, 4, 7, 1, 1, 2, 1, 2, 1, 4, 2, 0]


*/