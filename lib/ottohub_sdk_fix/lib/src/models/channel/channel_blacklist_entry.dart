import 'package:json_annotation/json_annotation.dart';

part 'channel_blacklist_entry.g.dart';

/// 频道黑名单条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ChannelBlacklistEntry {
  final int uid;
  final String username;
  final String? avatarUrl;
  final String? reason;
  final int? operatorUid;
  final String? operatorName;
  final String blacklistedAt;

  const ChannelBlacklistEntry({
    required this.uid,
    required this.username,
    this.avatarUrl,
    this.reason,
    this.operatorUid,
    this.operatorName,
    required this.blacklistedAt,
  });

  factory ChannelBlacklistEntry.fromJson(Map<String, dynamic> json) =>
      _$ChannelBlacklistEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelBlacklistEntryToJson(this);
}
