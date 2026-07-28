import 'package:skf/adapters/bilibili/models/model_owner.dart';

class Avatar extends Owner {
  Pendant? pendant;
  BaseOfficialVerify? officialVerify;
  Vip? vip;

  Avatar.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['pendant'] != null) pendant = Pendant.fromJson(json['pendant']);
    if (json['official_verify'] != null) {
      officialVerify = BaseOfficialVerify.fromJson(json['official_verify']);
    }
    if (json['vip'] != null) vip = Vip.fromJson(json['vip']);
  }
}

class Pendant {
  String? image;

  Pendant.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'image': image,
  };
}

class BaseOfficialVerify {
  int? type;
  String? desc;

  BaseOfficialVerify.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'desc': desc,
  };
}

class Vip {
  int? type;
  late int status;
  Label? label;

  Vip.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? json['vipType'];
    status = json['status'] ?? json['vipStatus'] ?? 0;
    if (json['label'] != null) label = Label.fromJson(json['label']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'status': status,
    'label': label?.toJson(),
  };
}

class Label {
  String? text;

  Label.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text': text,
  };
}
