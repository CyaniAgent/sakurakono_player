class MatchTeam {
  String? title;
  String? logo;

  MatchTeam({
    this.title,
    this.logo,
  });

  factory MatchTeam.fromJson(Map<String, dynamic> json) => MatchTeam(
    title: json['title'] as String?,
    logo: json['logo'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'logo': logo,
  };
}
