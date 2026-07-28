import 'dart:convert';

class MsgSysItem {
  int? id;
  int? cursor;
  String? title;
  String? content;
  String? timeAt;

  MsgSysItem({
    this.id,
    this.cursor,
    this.title,
    this.content,
    this.timeAt,
  });

  MsgSysItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    cursor = json['cursor'] as int?;
    title = json['title'] as String?;
    content = json['content'] as String?;
    if (content != null) {
      try {
        dynamic json = jsonDecode(content!);
        if (json?['web'] != null) {
          content = json['web'];
        }
      } catch (_) {}
    }
    timeAt = json['time_at'] as String?;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'cursor': cursor,
    'title': title,
    'content': content,
    'time_at': timeAt,
  };
}
