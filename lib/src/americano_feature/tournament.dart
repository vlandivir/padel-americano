// ignore_for_file: avoid_print

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


}
