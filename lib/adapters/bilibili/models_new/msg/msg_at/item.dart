import 'package:skf/adapters/bilibili/models_new/msg/msg_at/content.dart';
import 'package:skf/adapters/bilibili/models_new/msg/msg_at/user.dart';

class MsgAtItem {
  int? id;
  User? user;
  MsgAtContent? item;
  int? atTime;

  MsgAtItem({this.id, this.user, this.item, this.atTime});

  factory MsgAtItem.fromJson(Map<String, dynamic> json) => MsgAtItem(
    id: json['id'] as int?,
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),
    item: json['item'] == null
        ? null
        : MsgAtContent.fromJson(json['item'] as Map<String, dynamic>),
    atTime: json['at_time'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'user': user?.toJson(),
    'item': item?.toJson(),
    'at_time': atTime,
  };
}
