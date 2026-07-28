class Season {
  String? title;
  String? logo;

  Season({
    this.title,
    this.logo,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
    title: json['title'] as String?,
    logo: json['logo'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'logo': logo,
  };
}
