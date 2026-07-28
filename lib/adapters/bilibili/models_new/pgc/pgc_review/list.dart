import 'package:skf/adapters/bilibili/models_new/pgc/pgc_review/author.dart';
import 'package:skf/adapters/bilibili/models_new/pgc/pgc_review/stat.dart';

class PgcReviewItemModel {
  Author? author;
  String? title;
  String? content;
  String? pushTimeStr;
  int? reviewId;
  late int score;
  Stat? stat;
  int? articleId;

  PgcReviewItemModel({
    this.author,
    this.title,
    this.content,
    this.pushTimeStr,
    this.reviewId,
    required this.score,
    this.stat,
    this.articleId,
  });

  factory PgcReviewItemModel.fromJson(Map<String, dynamic> json) =>
      PgcReviewItemModel(
        articleId: json['article_id'],
        author: json['author'] == null
            ? null
            : Author.fromJson(json['author'] as Map<String, dynamic>),
        title: json['title'] as String?,
        content: json['content'] as String?,
        pushTimeStr: json['push_time_str'] as String?,
        reviewId: json['review_id'] as int?,
        score: json['score'] == null ? 0 : json['score'] ~/ 2,
        stat: json['stat'] == null
            ? null
            : Stat.fromJson(json['stat'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (articleId != null) 'article_id': articleId,
    if (author != null) 'author': author!.toJson(),
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    if (pushTimeStr != null) 'push_time_str': pushTimeStr,
    if (reviewId != null) 'review_id': reviewId,
    'score': score * 2,
    if (stat != null) 'stat': stat!.toJson(),
  };
}
