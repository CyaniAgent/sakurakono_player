import 'package:json_annotation/json_annotation.dart';
import 'timeline_item.dart';

part 'timeline_list_data.g.dart';

/// 动态时间线列表响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class TimelineListData {
  final List<TimelineItem> timelineList;

  const TimelineListData({
    required this.timelineList,
  });

  factory TimelineListData.fromJson(Map<String, dynamic> json) =>
      _$TimelineListDataFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineListDataToJson(this);
}
