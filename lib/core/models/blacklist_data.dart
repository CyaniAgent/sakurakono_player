import 'package:skf/core/models/blacklist_item.dart' show CoreBlackListItem;

/// Core blacklist data model — adapter-independent.
///
/// Contains only fields used in repository interface return types:
/// [list] and [total]. Adapter-specific JSON logic lives in the adapter
/// layer; this model can be constructed from any source.
class CoreBlackListData {
  List<CoreBlackListItem>? list;
  int? total;

  CoreBlackListData({this.list, this.total});

  factory CoreBlackListData.fromJson(Map<String, dynamic> json) => CoreBlackListData(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => CoreBlackListItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: json['total'] as int?,
  );
}
