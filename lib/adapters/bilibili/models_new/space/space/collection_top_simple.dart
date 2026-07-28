import 'package:skf/adapters/bilibili/models_new/space/space/top.dart';

class CollectionTopSimple {
  Top? top;

  CollectionTopSimple({
    this.top,
  });

  factory CollectionTopSimple.fromJson(Map<String, dynamic> json) {
    return CollectionTopSimple(
      top: json['top'] == null
          ? null
          : Top.fromJson(json['top'] as Map<String, dynamic>),
    );
  }
}
