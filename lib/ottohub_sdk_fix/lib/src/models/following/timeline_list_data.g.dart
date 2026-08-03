// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_list_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimelineListData _$TimelineListDataFromJson(Map<String, dynamic> json) =>
    TimelineListData(
      timelineList: (json['timeline_list'] as List<dynamic>)
          .map((e) => TimelineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TimelineListDataToJson(TimelineListData instance) =>
    <String, dynamic>{'timeline_list': instance.timelineList};
