class PgcConditionValue {
  String? keyword;
  String? name;

  PgcConditionValue({
    this.keyword,
    this.name,
  });

  PgcConditionValue.fromJson(Map json) {
    keyword = json['keyword'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (keyword != null) 'keyword': keyword,
    if (name != null) 'name': name,
  };
}
