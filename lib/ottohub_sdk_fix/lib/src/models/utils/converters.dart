import 'package:json_annotation/json_annotation.dart';

/// 将 JSON 中的 String 或 num 转换为 int。
///
/// 老版 API 经常将数值以字符串形式返回（如 `"like_count": "1"`），
/// 该转换器在此场景下安全地将 `String` / `num` 统一转为 `int`。
class StringToIntConverter implements JsonConverter<int, Object?> {
  const StringToIntConverter();

  @override
  int fromJson(Object? json) {
    if (json == null) return 0;
    if (json is String) return int.tryParse(json) ?? 0;
    return (json as num).toInt();
  }

  @override
  Object? toJson(int value) => value;
}

/// 将 JSON 中的 String 或 num 转换为 int?。
///
/// 与 [StringToIntConverter] 类似，但允许 `null` 值。
class StringToNullableIntConverter implements JsonConverter<int?, Object?> {
  const StringToNullableIntConverter();

  @override
  int? fromJson(Object? json) {
    if (json == null) return null;
    if (json is String) return int.tryParse(json);
    return (json as num?)?.toInt();
  }

  @override
  Object? toJson(int? value) => value;
}

/// 将 JSON 中的 String 或 num 转换为 num?。
///
/// 用于接收老版 API 返回的字符串型数值，支持浮点数及 null。
class StringToNullableNumConverter implements JsonConverter<num?, Object?> {
  const StringToNullableNumConverter();

  @override
  num? fromJson(Object? json) {
    if (json == null) return null;
    if (json is String) return num.tryParse(json);
    return json as num?;
  }

  @override
  Object? toJson(num? value) => value;
}
