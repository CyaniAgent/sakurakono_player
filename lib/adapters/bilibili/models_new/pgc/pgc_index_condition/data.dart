import 'package:skf/adapters/bilibili/models_new/pgc/pgc_index_condition/sort.dart';

class PgcIndexConditionData {
  List<PgcConditionFilter>? filter;
  List<PgcConditionOrder>? order;

  PgcIndexConditionData({this.filter, this.order});

  factory PgcIndexConditionData.fromJson(Map<String, dynamic> json) =>
      PgcIndexConditionData(
        filter: (json['filter'] as List<dynamic>?)
            ?.map((e) => PgcConditionFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
        order: (json['order'] as List<dynamic>?)
            ?.map((e) => PgcConditionOrder.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (filter != null)
      'filter': filter!.map((e) => e.toJson()).toList(),
    if (order != null) 'order': order!.map((e) => e.toJson()).toList(),
  };
}
