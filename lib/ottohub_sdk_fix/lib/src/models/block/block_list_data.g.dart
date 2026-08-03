// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_list_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockListData _$BlockListDataFromJson(Map<String, dynamic> json) =>
    BlockListData(
      list: (json['list'] as List<dynamic>)
          .map((e) => BlockRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$BlockListDataToJson(BlockListData instance) =>
    <String, dynamic>{
      'list': instance.list,
      'total': instance.total,
      'page': instance.page,
      'page_size': instance.pageSize,
      'total_pages': instance.totalPages,
    };
