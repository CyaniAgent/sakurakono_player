// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      uid: json['uid'] as String,
      token: json['token'] as String,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      ifTodayFirstLogin: json['if_today_first_login'] as String?,
      email: json['email'] as String?,
      isAudit: (json['is_audit'] as num?)?.toInt(),
      isAdmin: (json['is_admin'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'token': instance.token,
      'avatar_url': instance.avatarUrl,
      'cover_url': instance.coverUrl,
      'if_today_first_login': instance.ifTodayFirstLogin,
      'email': instance.email,
      'is_audit': instance.isAudit,
      'is_admin': instance.isAdmin,
    };
