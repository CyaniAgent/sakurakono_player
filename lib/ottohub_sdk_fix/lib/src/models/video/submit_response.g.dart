// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitResponse _$SubmitResponseFromJson(Map<String, dynamic> json) =>
    SubmitResponse(
      vid: (json['vid'] as num).toInt(),
      ifAddExperience: (json['if_add_experience'] as num).toInt(),
    );

Map<String, dynamic> _$SubmitResponseToJson(SubmitResponse instance) =>
    <String, dynamic>{
      'vid': instance.vid,
      'if_add_experience': instance.ifAddExperience,
    };
