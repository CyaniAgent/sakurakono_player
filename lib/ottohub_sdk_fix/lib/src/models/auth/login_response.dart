import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// 登录响应，包含用户身份信息及 Token。
@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponse {
  /// 用户 UID。
  final String uid;

  /// 登录凭证，后续 API 调用需附带此 Token。
  final String token;

  /// 用户头像 URL。
  final String? avatarUrl;

  /// 用户封面 URL。
  final String? coverUrl;

  /// 是否今日首次登录，值为 `"1"` 或 `"0"`（字符串）。
  final String? ifTodayFirstLogin;

  /// 用户邮箱。
  final String? email;

  /// 是否为审核人员，`1`=是，`0`=否。
  final int? isAudit;

  /// 是否为管理员，`1`=是，`0`=否。
  final int? isAdmin;

  const LoginResponse({
    required this.uid,
    required this.token,
    this.avatarUrl,
    this.coverUrl,
    this.ifTodayFirstLogin,
    this.email,
    this.isAudit,
    this.isAdmin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
