class MsgReplyContent {
  int? subjectId;
  int? businessId;
  String? business;
  String? nativeUri;
  String? rootReplyContent;
  String? sourceContent;
  String? targetReplyContent;

  MsgReplyContent({
    this.subjectId,
    this.businessId,
    this.business,
    this.nativeUri,
    this.rootReplyContent,
    this.sourceContent,
    this.targetReplyContent,
  });

  factory MsgReplyContent.fromJson(Map<String, dynamic> json) {
    return MsgReplyContent(
      subjectId: json['subject_id'] as int?,
      businessId: json['business_id'] as int?,
      business: json['business'] as String?,
      nativeUri: json['native_uri'] as String?,
      rootReplyContent: json['root_reply_content'] as String?,
      sourceContent: json['source_content'] as String?,
      targetReplyContent: json['target_reply_content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'subject_id': subjectId,
    'business_id': businessId,
    'business': business,
    'native_uri': nativeUri,
    'root_reply_content': rootReplyContent,
    'source_content': sourceContent,
    'target_reply_content': targetReplyContent,
  };
}
