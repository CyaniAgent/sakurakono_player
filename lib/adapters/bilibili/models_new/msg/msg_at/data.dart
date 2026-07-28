import 'package:skf/adapters/bilibili/models_new/msg/msg_at/cursor.dart';
import 'package:skf/adapters/bilibili/models_new/msg/msg_at/item.dart';

class MsgAtData {
  Cursor? cursor;
  List<MsgAtItem>? items;

  MsgAtData({this.cursor, this.items});

  factory MsgAtData.fromJson(Map<String, dynamic> json) => MsgAtData(
    cursor: json['cursor'] == null
        ? null
        : Cursor.fromJson(json['cursor'] as Map<String, dynamic>),
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => MsgAtItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'cursor': cursor?.toJson(),
    'items': items?.map((e) => e.toJson()).toList(),
  };
}
