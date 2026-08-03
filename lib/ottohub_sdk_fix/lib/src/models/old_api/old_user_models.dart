import 'package:json_annotation/json_annotation.dart';

part 'old_user_models.g.dart';

/// 用户摘要信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UserSummary {
  final int uid;
  final String username;
  final String? intro;
  final String? time;
  final String? avatarUrl;

  const UserSummary({
    required this.uid,
    required this.username,
    this.intro,
    this.time,
    this.avatarUrl,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$UserSummaryToJson(this);
}

/// 用户详细信息。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UserDetail {
  final int uid;
  final String username;
  final String? intro;
  final String? time;
  final String? sex;
  final String? honour;
  final int? experience;
  final String? avatarUrl;
  final String? coverUrl;
  final int? videoNum;
  final int? blogNum;
  final int? mediaNum;
  final int? followingsCount;
  final int? fansCount;

  const UserDetail({
    required this.uid,
    required this.username,
    this.intro,
    this.time,
    this.sex,
    this.honour,
    this.experience,
    this.avatarUrl,
    this.coverUrl,
    this.videoNum,
    this.blogNum,
    this.mediaNum,
    this.followingsCount,
    this.fansCount,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) =>
      _$UserDetailFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailToJson(this);
}
