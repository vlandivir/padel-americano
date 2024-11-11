// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_americano/src/americano_feature/split_by_pairs_sort.dart';

void createSchedule(List<dynamic> players) {
  if (players.length < 4) {
    print("Not enough players to create a schedule. At least 4 players are required.");
    return;
  }

  if (players.length > 16) {
    print("Players length can't be more than 16");
    return;
  }

  print('Start to create schedule');

  var schedule = generateSchedule(players.length);
  
  List<dynamic> allMatches = [];

  for (var round in schedule) {
    for (int i = 0; i < round.length - 1; i += 2) {
      allMatches.add({
        'round': i + 1,
        'team1': {
          'player1': players[round[i + 0][0] - 1], 
          'player2': players[round[i + 0][1] - 1], 
        },
        'team2': {
          'player1': players[round[i + 1][0] - 1], 
          'player2': players[round[i + 1][1] - 1], 
        }
      });
    }
  }

  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyString = encoder.convert(allMatches);
  print(prettyString);
}
