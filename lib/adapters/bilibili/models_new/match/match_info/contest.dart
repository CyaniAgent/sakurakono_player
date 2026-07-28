import 'package:skf/adapters/bilibili/models_new/match/match_info/season.dart';
import 'package:skf/adapters/bilibili/models_new/match/match_info/team.dart';

class MatchContest {
  String? gameStage;
  int? stime;
  int? homeId;
  int? awayId;
  int? homeScore;
  int? awayScore;
  int? liveRoom;
  Season? season;
  MatchTeam? homeTeam;
  MatchTeam? awayTeam;
  int? contestStatus;

  MatchContest({
    this.gameStage,
    this.stime,
    this.homeId,
    this.awayId,
    this.homeScore,
    this.awayScore,
    this.liveRoom,
    this.season,
    this.homeTeam,
    this.awayTeam,
    this.contestStatus,
  });

  factory MatchContest.fromJson(Map<String, dynamic> json) => MatchContest(
    gameStage: json['game_stage'] as String?,
    stime: json['stime'] as int?,
    homeId: json['home_id'] as int?,
    awayId: json['away_id'] as int?,
    homeScore: json['home_score'] as int?,
    awayScore: json['away_score'] as int?,
    liveRoom: json['live_room'] as int?,
    season: json['season'] == null
        ? null
        : Season.fromJson(json['season'] as Map<String, dynamic>),
    homeTeam: json['home_team'] == null
        ? null
        : MatchTeam.fromJson(json['home_team'] as Map<String, dynamic>),
    awayTeam: json['away_team'] == null
        ? null
        : MatchTeam.fromJson(json['away_team'] as Map<String, dynamic>),
    contestStatus: json['contest_status'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'game_stage': gameStage,
    'stime': stime,
    'home_id': homeId,
    'away_id': awayId,
    'home_score': homeScore,
    'away_score': awayScore,
    'live_room': liveRoom,
    'season': season?.toJson(),
    'home_team': homeTeam?.toJson(),
    'away_team': awayTeam?.toJson(),
    'contest_status': contestStatus,
  };
}
