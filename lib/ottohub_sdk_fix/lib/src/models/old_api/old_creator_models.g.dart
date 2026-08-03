// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_creator_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitResult _$SubmitResultFromJson(Map<String, dynamic> json) => SubmitResult(
  ifAddExperience: (json['if_add_experience'] as num?)?.toInt(),
  ifWarn: (json['if_warn'] as num?)?.toInt(),
);

Map<String, dynamic> _$SubmitResultToJson(SubmitResult instance) =>
    <String, dynamic>{
      'if_add_experience': ?instance.ifAddExperience,
      'if_warn': ?instance.ifWarn,
    };

ImageUploadResult _$ImageUploadResultFromJson(Map<String, dynamic> json) =>
    ImageUploadResult(imageUrl: json['image_url'] as String);

Map<String, dynamic> _$ImageUploadResultToJson(ImageUploadResult instance) =>
    <String, dynamic>{'image_url': instance.imageUrl};

NewTokenResponse _$NewTokenResponseFromJson(Map<String, dynamic> json) =>
    NewTokenResponse(newToken: json['new_token'] as String);

Map<String, dynamic> _$NewTokenResponseToJson(NewTokenResponse instance) =>
    <String, dynamic>{'new_token': instance.newToken};
