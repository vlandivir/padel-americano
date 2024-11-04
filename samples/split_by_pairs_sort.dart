// ignore_for_file: avoid_print

import 'dart:math';

void printPairsByRounds(List<List<int>> pairs, int pairsPerRound) {
  for (int i = 0; i < pairs.length; i += pairsPerRound) {
    print(pairs.sublist(i, min(i + pairsPerRound, pairs.length)));
  }
}

bool sortPlayers (int players, List<List<int>> possiblePairs, {bool printLog = false}) {
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
  return pointer == possiblePairs.length;
}

void main(List<String> args) {

  for (int players = 20; players <= 20; players += 1) {
    print('\n\n\n $players players');
    int matchesPerRound = players ~/ 4;
    int pairsPerRound = matchesPerRound * 2;

    // Create a list of all possible pairs
    List<List<int>> possiblePairs = [];
    for (int i = 1; i <= players; i++) {
      for (int j = i + 1; j <= players; j++) {
        possiblePairs.add([i, j]);
      }
    }

    for (int j = 0; j < 199999; j += 1) {
      var scheduled = sortPlayers(players, possiblePairs, printLog: j % 1000 == 0);
      // print('players: $players, is scheduled?? $scheduled on step $j');
      // printPairsByRounds(possiblePairs, pairsPerRound);

      if (scheduled) {
        print('players: $players, is scheduled?? $scheduled on step $j');
        break;
      }
      
      if ((players == 12 || players > 16) && j % 1000 == 0) {
        printPairsByRounds(possiblePairs, pairsPerRound);
        possiblePairs.shuffle();
      } else {
        possiblePairs = possiblePairs.reversed.toList();
      }

    }

    print('\n\n\nfinal');
    printPairsByRounds(possiblePairs, pairsPerRound);
  }

}

