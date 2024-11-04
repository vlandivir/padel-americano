// ignore_for_file: avoid_print, dead_code

import 'dart:math';

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

  // bool playersShuffleRule = players == 12 || players > 16;
  bool playersShuffleRule = true;

  if (playersShuffleRule) {
    possiblePairs.shuffle();
  }

  for (int j = 0; j < 9999999; j += 1) {
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
        var sortedPointer = max(0, min((pointer ~/ pairsPerRound) * pairsPerRound, possiblePairs.length - pairsPerRound * 4));
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
  int left = 4;
  int right = 20;

  print(args);

  for (int players = left; players <= right; players += 1) {
    generateSchedule(players);
  }
}

