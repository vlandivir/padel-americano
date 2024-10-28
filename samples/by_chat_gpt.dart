// ignore_for_file: avoid_print

void main() {
  int players = 11; // Example number of players
  int playersPerRound = 8;
  int rounds = 13;

  // Определяем количество появлений для каждого игрока
  Map<int, int> playerAppearances = {};
  int totalAppearances = rounds * playersPerRound; // 13 * 8 = 104

  // Распределяем появления: 6 игроков по 9 раз, 5 игроков по 10 раз
  List<int> playerList = List.generate(players, (index) => index + 1);
  playerList.shuffle(); // Перемешиваем для случайности

  for (int i = 0; i < players; i++) {
    if (i < 6) {
      playerAppearances[playerList[i]] = 9;
    } else {
      playerAppearances[playerList[i]] = 10;
    }
  }

  // Создаем список игроков с учетом количества их появлений
  List<int> playersPerMatches = [];
  playerAppearances.forEach((playerID, appearances) {
    for (int i = 0; i < appearances; i++) {
      playersPerMatches.add(playerID);
    }
  });

  // Перемешиваем список для случайного распределения
  playersPerMatches.shuffle();

  // Инициализируем структуру для хранения раундов
  List<List<int>> splitPlayers = List.generate(rounds, (_) => []);

  // Отслеживаем, в каких раундах участвует каждый игрок
  Map<int, Set<int>> playerRounds = {};
  for (int player in playerList) {
    playerRounds[player] = {};
  }

  // Отслеживаем количество встреч между парами игроков
  Map<String, int> pairMeetingCounts = {};

  // Функция для обновления количества встреч пар
  void updatePairMeetingCounts(List<int> roundPlayers) {
    for (int i = 0; i < roundPlayers.length; i++) {
      for (int j = i + 1; j < roundPlayers.length; j++) {
        int playerA = roundPlayers[i];
        int playerB = roundPlayers[j];
        String key = playerA < playerB ? '$playerA-$playerB' : '$playerB-$playerA';
        pairMeetingCounts[key] = (pairMeetingCounts[key] ?? 0) + 1;
      }
    }
  }

  // Распределяем игроков по раундам
  for (int i = 0; i < playersPerMatches.length; i++) {
    int playerID = playersPerMatches[i];

    // Поиск подходящего раунда для игрока
    int bestRound = -1;
    int minMaxPairCount = 9999;

    for (int r = 0; r < rounds; r++) {
      if (splitPlayers[r].length >= playersPerRound) continue;
      if (playerRounds[playerID]!.contains(r)) continue;

      // Проверяем, сколько раз игрок встречался с другими игроками в этом раунде
      int maxPairCount = 0;
      for (int otherPlayer in splitPlayers[r]) {
        String key = playerID < otherPlayer ? '$playerID-$otherPlayer' : '$otherPlayer-$playerID';
        int pairCount = (pairMeetingCounts[key] ?? 0) + 1;
        if (pairCount > maxPairCount) {
          maxPairCount = pairCount;
        }
      }

      // Выбираем раунд с минимальным максимальным количеством встреч пар
      if (maxPairCount < minMaxPairCount) {
        minMaxPairCount = maxPairCount;
        bestRound = r;
      }
    }

    if (bestRound != -1) {
      splitPlayers[bestRound].add(playerID);
      playerRounds[playerID]!.add(bestRound);
      updatePairMeetingCounts(splitPlayers[bestRound]);
    } else {
      print('Не удалось назначить игрока $playerID в раунд.');
    }
  }

  // Выводим распределение игроков по раундам
  for (int r = 0; r < rounds; r++) {
    print('Раунд ${r + 1}: ${splitPlayers[r]}');
  }

  // Анализируем количество встреч между парами игроков
  print('\nКоличество встреч между парами игроков:');
  int maxPairMeetingCount = 0;
  int minPairMeetingCount = 9999;

  pairMeetingCounts.forEach((key, count) {
    if (count > maxPairMeetingCount) maxPairMeetingCount = count;
    if (count < minPairMeetingCount) minPairMeetingCount = count;
    print('Пара $key встречалась $count раз(а)');
  });

  print('\nМаксимальное количество встреч между парой игроков: $maxPairMeetingCount');
  print('Минимальное количество встреч между парой игроков: $minPairMeetingCount');
}
