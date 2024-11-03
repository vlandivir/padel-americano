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

int countMeetings(List<List<int>> splitPlayers, int player1, int player2) {
  int count = 0;
  for (var round in splitPlayers) {
    if (round.contains(player1) && round.contains(player2)) {
      count++;
    }
  }
  return count;
}

List<List<int>> createMeetingsMatrix(List<List<int>> splitPlayers, int players) {
  List<List<int>> meetingsMatrix = List.generate(players, (_) => List.filled(players, 0));

  for (int i = 1; i <= players; i++) {
    for (int j = 1; j <= players; j++) {
      if (i != j) {
        meetingsMatrix[i - 1][j - 1] = countMeetings(splitPlayers, i, j);
      }
    }
  }

  return meetingsMatrix;
}

List<T> shiftLeft<T>(List<T> list, int N) {
  int n = N % list.length; // Обработка случая, когда N больше длины списка
  return List<T>.from(list.sublist(n))..addAll(list.sublist(0, n));
}

void main() {
  int players = 6; // Example number of players
  int pairs = (players * (players - 1)) ~/ 2;
  int matches = pairs ~/ 2;
  int matchesPerRound = players ~/ 4;
  int rounds = matches ~/ matchesPerRound;
  int playersPerRound = matchesPerRound * 4;

  // Create a flat array to store each player's opponents with (n - 1) elements
  List<int> playersPerMatches = List.generate(players * (players - 1), (index) => (index % players) + 1);
  print(playersPerMatches);

  List<int> sample = [
    1, 2, 3, 4,
    5, 6, 1, 3,
    2, 4, 5, 1,
    6, 2, 4, 5,
    3, 6, 2, 5,
    1, 4, 3, 5,
    6, 1, 2, 3,
  ];
  print(sample);

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

  while(playersPerMatches.isNotEmpty) {
    if (sortedPlayers.length % playersPerRound == 0) {
      playersInRound = List.generate(playersPerRound, (_) => 0);
    } 

    int player1 = 0;
    int player2 = 0;
    List<int> pair = [];

    int i = shift;
    for (; i < playersPerMatches.length; i += 1) {
      player1 = playersPerMatches[i];
      if (!playersInRound.contains(player1)) {
        break;
      }
    }
    // print({sortedPlayers, playersInRound, playersPerMatches});

    bool pairFound = false;
    for (int i = shift; i < playersPerMatches.length; i += 1) {
      player2 = playersPerMatches[i];
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

    if (!pairFound && shift < playersPerMatches.length) {
      shift += 1;
      continue;
    }
    shift = 0;

    playersInRound.add(player1);
    playersInRound.add(player2);

    sortedPlayers.add(player1);
    sortedPlayers.add(player2);
    playersPerMatches.remove(player1); 
    playersPerMatches.remove(player2);
    playersInRound = playersInRound.sublist(2);

    // print({sortedPlayers, playersInRound, playersPerMatches});
    // break;
  }

  print(sortedPlayers);

  // Split the flat array into multiple arrays of length playersPerRound
  List<List<int>> splitPlayers = [];
  for (int i = 0; i < sortedPlayers.length; i += playersPerRound) {
    List<int> chunk = sortedPlayers.sublist(i, (i + playersPerRound) > sortedPlayers.length ? sortedPlayers.length : (i + playersPerRound));
    splitPlayers.add(chunk);
  }

  // Create and print the meetings matrix based on splitPlayers
  List<List<int>> meetingsMatrix = createMeetingsMatrix(splitPlayers, players);
  printIndented(meetingsMatrix);
  printIndented(splitPlayers);
}
