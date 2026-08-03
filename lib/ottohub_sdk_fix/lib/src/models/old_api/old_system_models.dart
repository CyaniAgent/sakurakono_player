import 'package:json_annotation/json_annotation.dart';

part 'old_system_models.g.dart';

/// 轮播图幻灯片。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class Slide {
  final String imgUrl;
  final String? title;
  final String? href;

  const Slide({
    required this.imgUrl,
    this.title,
    this.href,
  });

  factory Slide.fromJson(Map<String, dynamic> json) =>
      _$SlideFromJson(json);

  Map<String, dynamic> toJson() => _$SlideToJson(this);
}

/// 启动屏配置。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class LaunchScreen {
  final String launchScreenUrl;
  final String? darkLaunchScreenUrl;

  const LaunchScreen({
    required this.launchScreenUrl,
    this.darkLaunchScreenUrl,
  });

  factory LaunchScreen.fromJson(Map<String, dynamic> json) =>
      _$LaunchScreenFromJson(json);

  Map<String, dynamic> toJson() => _$LaunchScreenToJson(this);
}

/// 法律文档链接配置。
@JsonSerializable(fieldRename: FieldRename.snake)
class LegalDocuments {
  final String termsOfServiceUrl;
  final String privacyPolicyUrl;
  final String platformContentReviewSpecificationUrl;

  const LegalDocuments({
    required this.termsOfServiceUrl,
    required this.privacyPolicyUrl,
    required this.platformContentReviewSpecificationUrl,
  });

  factory LegalDocuments.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentsFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocumentsToJson(this);
}
