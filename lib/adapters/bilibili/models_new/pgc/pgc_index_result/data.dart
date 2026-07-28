import 'package:skf/adapters/bilibili/models_new/pgc/pgc_index_result/list.dart';

class PgcIndexResult {
  int? hasNext;
  List<PgcIndexItem>? list;

  PgcIndexResult({this.hasNext, this.list});

  factory PgcIndexResult.fromJson(Map<String, dynamic> json) => PgcIndexResult(
    hasNext: json['has_next'] as int?,
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => PgcIndexItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (hasNext != null) 'has_next': hasNext,
    if (list != null) 'list': list!.map((e) => e.toJson()).toList(),
  };
}
