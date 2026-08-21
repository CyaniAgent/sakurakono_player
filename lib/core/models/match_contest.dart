import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_contest.freezed.dart';

/// Core model for match season info.
@freezed
abstract class CoreSeason with _$CoreSeason {
  const factory CoreSeason({
    String? title,
    String? logo,
  }) = _CoreSeason;

  static CoreSeason fromJson(Map<String, dynamic> json) => CoreSeason(
    title: json['title'] as String?,
    logo: json['logo'] as String?,
  );
}

/// Core model for match team info.
@freezed
abstract class CoreMatchTeam with _$CoreMatchTeam {
  const factory CoreMatchTeam({
    String? title,
    String? logo,
  }) = _CoreMatchTeam;

  static CoreMatchTeam fromJson(Map<String, dynamic> json) => CoreMatchTeam(
    title: json['title'] as String?,
    logo: json['logo'] as String?,
  );
}

/// Core model for a match contest.
@freezed
abstract class CoreMatchContest with _$CoreMatchContest {
  const factory CoreMatchContest({
    String? gameStage,
    int? stime,
    int? homeId,
    int? awayId,
    int? homeScore,
    int? awayScore,
    int? liveRoom,
    CoreSeason? season,
    CoreMatchTeam? homeTeam,
    CoreMatchTeam? awayTeam,
    int? contestStatus,
  }) = _CoreMatchContest;

  static CoreMatchContest fromJson(Map<String, dynamic> json) =>
      CoreMatchContest(
        gameStage: json['game_stage'] as String?,
        stime: json['stime'] as int?,
        homeId: json['home_id'] as int?,
        awayId: json['away_id'] as int?,
        homeScore: json['home_score'] as int?,
        awayScore: json['away_score'] as int?,
        liveRoom: json['live_room'] as int?,
        season: json['season'] == null
            ? null
            : CoreSeason.fromJson(json['season'] as Map<String, dynamic>),
        homeTeam: json['home_team'] == null
            ? null
            : CoreMatchTeam.fromJson(
                json['home_team'] as Map<String, dynamic>),
        awayTeam: json['away_team'] == null
            ? null
            : CoreMatchTeam.fromJson(
                json['away_team'] as Map<String, dynamic>),
        contestStatus: json['contest_status'] as int?,
      );
}
