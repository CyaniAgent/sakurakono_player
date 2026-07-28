/// Core model for a music artist.
class CoreArtist {
  int? mid;
  String? name;
  String? face;
  String? identity;

  CoreArtist({
    this.mid,
    this.name,
    this.face,
    this.identity,
  });

  factory CoreArtist.fromJson(Map<String, dynamic> json) {
    return CoreArtist(
      mid: json['mid'],
      name: json['name'],
      face: json['face'],
      identity: json['identity'],
    );
  }
}

/// Core model for song heat data point.
class CoreSongHeat {
  CoreSongHeat({
    required this.date,
    required this.heat,
  });

  final int date;
  final int heat;

  factory CoreSongHeat.fromJson(Map<String, dynamic> json) {
    return CoreSongHeat(
      date: json['date'],
      heat: json['heat'],
    );
  }
}

/// Core model for hot song heat info.
class CoreHotSongHeat {
  CoreHotSongHeat({
    required this.lastHeat,
    required this.songHeat,
  });

  final int? lastHeat;
  final List<CoreSongHeat>? songHeat;

  factory CoreHotSongHeat.fromJson(Map<String, dynamic> json) {
    return CoreHotSongHeat(
      lastHeat: json['last_heat'],
      songHeat: (json['song_heat'] as List?)?.reversed
          .map((x) => CoreSongHeat.fromJson(x))
          .toList(),
    );
  }
}

/// Core model for music comment info.
class CoreMusicComment {
  CoreMusicComment({
    required this.nums,
    required this.oid,
    required this.pageType,
  });

  final int? nums;
  final int? oid;
  final int? pageType;

  factory CoreMusicComment.fromJson(Map<String, dynamic> json) {
    return CoreMusicComment(
      nums: json['nums'],
      oid: json['oid'],
      pageType: json['page_type'],
    );
  }
}

/// Core model for BGM (music) detail.
class CoreMusicDetail {
  CoreMusicDetail({
    required this.musicTitle,
    required this.originArtist,
    required this.originArtistList,
    required this.mvAid,
    required this.mvCid,
    required this.mvBvid,
    required this.mvCover,
    required this.wishListen,
    required this.wishCount,
    required this.musicSource,
    required this.album,
    required this.artistsList,
    required this.listenPv,
    required this.achievement,
    required this.hotSongHeat,
    required this.musicComment,
    required this.musicRelation,
    required this.musicPublish,
  });

  final String? musicTitle;
  final String? originArtist;
  final String? originArtistList;
  final int? mvAid;
  final int mvCid;
  final String? mvBvid;
  final String? mvCover;
  bool? wishListen;
  int? wishCount;
  final String? musicSource;
  final String? album;
  final List<CoreArtist>? artistsList;
  final int? listenPv;
  final List<String> achievement;
  final CoreHotSongHeat? hotSongHeat;
  final CoreMusicComment? musicComment;
  final int? musicRelation;
  final String? musicPublish;

  factory CoreMusicDetail.fromJson(Map<String, dynamic> json) {
    return CoreMusicDetail(
      musicTitle: json['music_title'],
      originArtist: json['origin_artist'],
      originArtistList: json['origin_artist_list'],
      mvAid: json['mv_aid'],
      mvCid: json['mv_cid'] ?? 0,
      mvBvid: json['mv_bvid'],
      mvCover: json['mv_cover'],
      wishListen: json['wish_listen'],
      wishCount: json['wish_count'],
      musicSource: json['music_source'],
      album: json['album'],
      artistsList: (json['artists_list'] as List?)
          ?.map((x) => CoreArtist.fromJson(x))
          .toList(),
      listenPv: json['listen_pv'],
      achievement: [
        ...?json['achievement'],
        ?json['music_rank'],
        ?json['recreation_rank'],
      ],
      hotSongHeat: json['hot_song_heat'] == null
          ? null
          : CoreHotSongHeat.fromJson(json['hot_song_heat']),
      musicComment: json['music_comment'] == null
          ? null
          : CoreMusicComment.fromJson(json['music_comment']),
      musicRelation: json['music_relation'],
      musicPublish: json['music_publish'],
    );
  }
}

/// Core model for a label in BGM recommendations.
class CoreLabelList {
  CoreLabelList({
    required this.name,
  });

  final String? name;

  factory CoreLabelList.fromJson(Map<String, dynamic> json) {
    return CoreLabelList(
      name: json['name'],
    );
  }
}

/// Core model for a BGM recommendation item.
class CoreBgmRecommend {
  CoreBgmRecommend({
    required this.bvid,
    required this.cid,
    required this.cover,
    required this.title,
    required this.upNickName,
    required this.play,
    required this.danmu,
    required this.duration,
    required this.labelList,
  });

  final String? bvid;
  final int? cid;
  final String? cover;
  final String? title;
  final String? upNickName;
  final int? play;
  final int? danmu;
  final int? duration;
  final List<CoreLabelList>? labelList;

  factory CoreBgmRecommend.fromJson(Map<String, dynamic> json) {
    return CoreBgmRecommend(
      bvid: json['bvid'],
      cid: json['cid'],
      cover: json['cover'],
      title: json['title'],
      upNickName: json['up_nick_name'],
      play: json['play'],
      danmu: json['danmu'],
      duration: json['duration'],
      labelList: (json['label_list'] as List?)
          ?.map((x) => CoreLabelList.fromJson(x))
          .toList(),
    );
  }
}