import 'package:skf/adapters/bilibili/models/common/sponsor_block/segment_type.dart';

class SegmentItemModel {
  String? cid;
  String category;
  String? actionType;
  List<int> segment;
  String uuid;
  num? videoDuration;
  int? votes;

  SegmentItemModel({
    this.cid,
    required this.category,
    this.actionType,
    required this.segment,
    required this.uuid,
    this.videoDuration,
    this.votes,
  });

  factory SegmentItemModel.fromJson(Map<String, dynamic> json) =>
      SegmentItemModel(
        cid: json["cid"],
        category: json["category"],
        actionType: json["actionType"],
        segment: (json["segment"] as List)
            .map((e) => ((e as num) * 1000).round())
            .toList(),
        uuid: json["UUID"],
        videoDuration: json["videoDuration"] == null
            ? null
            : (json["videoDuration"] as num) * 1000,
        votes: json["votes"],
      );

  factory SegmentItemModel.fromPgcJson(
    Map<String, dynamic> json,
    num? videoDuration,
  ) => SegmentItemModel(
    category: switch (json['clipType']) {
      'CLIP_TYPE_OP' => SegmentType.intro.name,
      'CLIP_TYPE_ED' => SegmentType.outro.name,
      _ => SegmentType.sponsor.name,
    },
    segment: [
      ((json['start'] as num) * 1000).round(),
      ((json['end'] as num) * 1000).round(),
    ],
    uuid: '',
    videoDuration: videoDuration,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (cid != null) 'cid': cid,
    'category': category,
    if (actionType != null) 'actionType': actionType,
    'segment': segment
        .map((e) => e / 1000)
        .toList(),
    'UUID': uuid,
    if (videoDuration != null) 'videoDuration': videoDuration! / 1000,
    if (votes != null) 'votes': votes,
  };
}
