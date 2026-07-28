class MsgLikeDetailCard {
  String? business;
  String? title;

  MsgLikeDetailCard({
    this.business,
    this.title,
  });

  factory MsgLikeDetailCard.fromJson(Map<String, dynamic> json) =>
      MsgLikeDetailCard(
        business: json['business'] as String?,
        title: json['title'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'business': business,
    'title': title,
  };
}
