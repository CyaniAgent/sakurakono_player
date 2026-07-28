class BgmRecommend {
  BgmRecommend({
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
  final List<LabelList>? labelList;

  factory BgmRecommend.fromJson(Map<String, dynamic> json) {
    return BgmRecommend(
      bvid: json["bvid"],
      cid: json["cid"],
      cover: json["cover"],
      title: json["title"],
      upNickName: json["up_nick_name"],
      play: json["play"],
      danmu: json["danmu"],
      duration: json["duration"],
      labelList: (json["label_list"] as List?)
          ?.map((x) => LabelList.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'bvid': bvid,
    'cid': cid,
    'cover': cover,
    'title': title,
    'up_nick_name': upNickName,
    'play': play,
    'danmu': danmu,
    'duration': duration,
    'label_list': labelList?.map((x) => x.toJson()).toList(),
  };
}

class LabelList {
  LabelList({
    required this.name,
  });

  final String? name;

  factory LabelList.fromJson(Map<String, dynamic> json) {
    return LabelList(
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
  };
}
