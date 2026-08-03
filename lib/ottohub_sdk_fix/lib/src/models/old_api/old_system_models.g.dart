// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_system_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Slide _$SlideFromJson(Map<String, dynamic> json) => Slide(
  imgUrl: json['img_url'] as String,
  title: json['title'] as String?,
  href: json['href'] as String?,
);

Map<String, dynamic> _$SlideToJson(Slide instance) => <String, dynamic>{
  'img_url': instance.imgUrl,
  'title': ?instance.title,
  'href': ?instance.href,
};

LaunchScreen _$LaunchScreenFromJson(Map<String, dynamic> json) => LaunchScreen(
  launchScreenUrl: json['launch_screen_url'] as String,
  darkLaunchScreenUrl: json['dark_launch_screen_url'] as String?,
);

Map<String, dynamic> _$LaunchScreenToJson(LaunchScreen instance) =>
    <String, dynamic>{
      'launch_screen_url': instance.launchScreenUrl,
      'dark_launch_screen_url': ?instance.darkLaunchScreenUrl,
    };

LegalDocuments _$LegalDocumentsFromJson(Map<String, dynamic> json) =>
    LegalDocuments(
      termsOfServiceUrl: json['terms_of_service_url'] as String,
      privacyPolicyUrl: json['privacy_policy_url'] as String,
      platformContentReviewSpecificationUrl:
          json['platform_content_review_specification_url'] as String,
    );

Map<String, dynamic> _$LegalDocumentsToJson(LegalDocuments instance) =>
    <String, dynamic>{
      'terms_of_service_url': instance.termsOfServiceUrl,
      'privacy_policy_url': instance.privacyPolicyUrl,
      'platform_content_review_specification_url':
          instance.platformContentReviewSpecificationUrl,
    };
