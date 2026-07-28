import 'package:skf/adapters/bilibili/models/model_avatar.dart';

class ImUserInfosData {
  int? mid;
  String? name;
  String? face;
  String? sign;
  Vip? vip;
  Pendant? pendant;
  BaseOfficialVerify? official;

  ImUserInfosData({
    this.mid,
    this.name,
    this.face,
    this.sign,
    this.vip,
    this.pendant,
    this.official,
  });

  factory ImUserInfosData.fromJson(Map<String, dynamic> json) =>
      ImUserInfosData(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        sign: json['sign'] as String?,
        vip: json['vip'] == null
            ? null
            : Vip.fromJson(json['vip'] as Map<String, dynamic>),
        pendant: json['pendant'] == null
            ? null
            : Pendant.fromJson(json['pendant'] as Map<String, dynamic>),
        official: json['official'] == null
            ? null
            : BaseOfficialVerify.fromJson(
                json['official'] as Map<String, dynamic>,
              ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'mid': mid,
    'name': name,
    'face': face,
    'sign': sign,
    'vip': vip?.toJson(),
    'pendant': pendant?.toJson(),
    'official': official?.toJson(),
  };
}
