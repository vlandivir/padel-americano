// ignore_for_file: avoid_print
void printIndented(dynamic data, [int indent = 0]) {
  if (data is List) {
    if (indent == 0) {
      print('${' ' * indent}[');
      for (var value in data) {
        printIndented(value, indent + 2);
      }
      print('${' ' * indent}]');
    } else {
      print('${' ' * indent}[${data.join(', ')}]');
    }
  } else {
    print('${' ' * indent}$data');
  }
}

void splitPlayers(int players) {
  int pairs = (players * (players - 1)) ~/ 2;
  int matches = pairs ~/ 2;
  int matchesPerRound = players ~/ 4;
  int rounds = matches ~/ matchesPerRound;
  int playersPerRound = matchesPerRound * 4;

  // Create a flat array to store each player's opponents with (n - 1) elements
  List<int> allPlayers = List.generate(players * (players - 1), (index) => (index % players) + 1);

  // Create a list of all possible pairs
  List<List<int>> possiblePairs = [];
  for (int i = 1; i <= players; i++) {
    for (int j = i + 1; j <= players; j++) {
      possiblePairs.add([i, j]);
    }
  }

  List<int> sortedPlayers = [];
  List<int> playersInRound = [];
  int shift = 0;

  while(allPlayers.isNotEmpty) {
    if (sortedPlayers.length % playersPerRound == 0) {
      playersInRound = List.generate(playersPerRound, (_) => 0);
    } 

    int player1 = 0;
    int player2 = 0;
    List<int> pair = [];

    int i = shift;
    for (; i < allPlayers.length; i += 1) {
      player1 = allPlayers[i];
      if (!playersInRound.contains(player1)) {
        break;
      }
    }

    bool pairFound = false;
    for (int i = shift; i < allPlayers.length; i += 1) {
      player2 = allPlayers[i];
      pair = [player1, player2];
      pair.sort();
      if (!playersInRound.contains(player2) && player2 != player1) {
        for (int j = 0; j < possiblePairs.length; j += 1) {
          List<int> currentPair = possiblePairs[j];
          if (currentPair[0] == pair[0] && currentPair[1] == pair[1]) {
            possiblePairs.remove(currentPair);
            pairFound = true;
            break;
          }
        }
        if (pairFound) {
          break;
        }
      }
    }

    if (!pairFound && shift < allPlayers.length) {
      shift += 1;
      continue;
    }
    shift = 0;

    playersInRound.add(player1);
    playersInRound.add(player2);
    sortedPlayers.add(player1);
    sortedPlayers.add(player2);
    allPlayers.remove(player1); 
    allPlayers.remove(player2);
    playersInRound = playersInRound.sublist(2);
  }

  // Split the flat array into multiple arrays of length playersPerRound
  List<List<int>> splittedPlayers = [];
  for (int i = 0; i < sortedPlayers.length; i += playersPerRound) {
    List<int> chunk = sortedPlayers.sublist(i, (i + playersPerRound) > sortedPlayers.length ? sortedPlayers.length : (i + playersPerRound));
    splittedPlayers.add(chunk);
  }

  printIndented(splittedPlayers);
}

void main() {
  splitPlayers(4);
  splitPlayers(5);
}
