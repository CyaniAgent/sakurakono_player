import 'package:freezed_annotation/freezed_annotation.dart';

part 'blacklist_item.freezed.dart';
part 'blacklist_item.g.dart';

/// Core blacklist item model — adapter-independent.
@freezed
abstract class CoreBlackListItem with _$CoreBlackListItem {
  const factory CoreBlackListItem({
    int? mid,
    int? mtime,
    String? uname,
    String? face,
  }) = _CoreBlackListItem;

  factory CoreBlackListItem.fromJson(Map<String, dynamic> json) =>
      _$CoreBlackListItemFromJson(json);
}
