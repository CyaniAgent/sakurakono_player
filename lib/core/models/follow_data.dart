import 'package:skf/core/models/follow_item.dart' show CoreFollowItemModel;

/// Core follow data model — adapter-independent.
///
/// Contains only fields used in repository interface return types:
/// [list] and [total]. Adapter-specific JSON logic lives in the adapter
/// layer; this model can be constructed from any source.
class CoreFollowData {
  List<CoreFollowItemModel>? list;
  int? total;

  CoreFollowData({required this.list, this.total});

  factory CoreFollowData.fromJson(Map<String, dynamic> json) => CoreFollowData(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreFollowItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int?,
      );
}
