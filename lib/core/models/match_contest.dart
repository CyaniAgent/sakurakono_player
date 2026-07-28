/// Core model for match season info.
class CoreSeason {
  String? title;
  String? logo;

  CoreSeason({
    this.title,
    this.logo,
  });

  factory CoreSeason.fromJson(Map<String, dynamic> json) => CoreSeason(
    title: json['title'] as String?,
    logo: json['logo'] as String?,
  );
}

/// Core model for match team info.
class CoreMatchTeam {
  String? title;
  String? logo;

  CoreMatchTeam({
    this.title,
    this.logo,
  });

  factory CoreMatchTeam.fromJson(Map<String, dynamic> json) => CoreMatchTeam(
    title: json['title'] as String?,
    logo: json['logo'] as String?,
  );
}

/// Core model for a match contest.
class CoreMatchContest {
  String? gameStage;
  int? stime;
  int? homeId;
  int? awayId;
  int? homeScore;
  int? awayScore;
  int? liveRoom;
  CoreSeason? season;
  CoreMatchTeam? homeTeam;
  CoreMatchTeam? awayTeam;
  int? contestStatus;

  CoreMatchContest({
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

  factory CoreMatchContest.fromJson(Map<String, dynamic> json) => CoreMatchContest(
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
        : CoreMatchTeam.fromJson(json['home_team'] as Map<String, dynamic>),
    awayTeam: json['away_team'] == null
        ? null
        : CoreMatchTeam.fromJson(json['away_team'] as Map<String, dynamic>),
    contestStatus: json['contest_status'] as int?,
  );
}