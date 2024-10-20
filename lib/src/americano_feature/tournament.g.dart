// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TournamentAdapter extends TypeAdapter<Tournament> {
  @override
  final int typeId = 0;

  @override
  Tournament read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tournament(
      name: fields[0] as String,
      numberOfPoints: fields[1] as int,
      numberOfCourts: fields[2] as int,
    )
      ..players = (fields[3] as List).cast<Player>()
      ..schedule = (fields[4] as List).cast<Round>();
  }

  @override
  void write(BinaryWriter writer, Tournament obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.numberOfPoints)
      ..writeByte(2)
      ..write(obj.numberOfCourts)
      ..writeByte(3)
      ..write(obj.players)
      ..writeByte(4)
      ..write(obj.schedule);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 1;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      name: fields[0] as String,
      id: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeamAdapter extends TypeAdapter<Team> {
  @override
  final int typeId = 2;

  @override
  Team read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Team(
      player1: fields[0] as Player,
      player2: fields[1] as Player,
    )..score = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, Team obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.player1)
      ..writeByte(1)
      ..write(obj.player2)
      ..writeByte(2)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchAdapter extends TypeAdapter<Match> {
  @override
  final int typeId = 3;

  @override
  Match read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Match(
      courtNumber: fields[0] as int,
      team1: fields[1] as Team,
      team2: fields[2] as Team,
    );
  }

  @override
  void write(BinaryWriter writer, Match obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.courtNumber)
      ..writeByte(1)
      ..write(obj.team1)
      ..writeByte(2)
      ..write(obj.team2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoundAdapter extends TypeAdapter<Round> {
  @override
  final int typeId = 4;

  @override
  Round read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Round(
      roundNumber: fields[0] as int,
      matches: (fields[1] as List).cast<Match>(),
    );
  }

  @override
  void write(BinaryWriter writer, Round obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.roundNumber)
      ..writeByte(1)
      ..write(obj.matches);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
