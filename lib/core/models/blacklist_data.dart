import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:skf/core/models/blacklist_item.dart' show CoreBlackListItem;

part 'blacklist_data.freezed.dart';

/// Core blacklist data model — adapter-independent.
///
/// Contains only fields used in repository interface return types:
/// [list] and [total]. Adapter-specific JSON logic lives in the adapter
/// layer; this model can be constructed from any source.
@freezed
abstract class CoreBlackListData with _$CoreBlackListData {
  const factory CoreBlackListData({
    List<CoreBlackListItem>? list,
    int? total,
  }) = _CoreBlackListData;

  static CoreBlackListData fromJson(Map<String, dynamic> json) =>
      CoreBlackListData(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreBlackListItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int?,
      );
}
