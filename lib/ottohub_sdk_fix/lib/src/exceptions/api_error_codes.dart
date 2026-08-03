/// API 错误码常量。
library;

// ============================================================
// 通用错误码
// ============================================================
final class GeneralErrorCodes {
  const GeneralErrorCodes._();

  /// 缺少必需参数
  static const String missingArgument = 'missing_argument';

  /// Token 无效或已过期
  static const String errorToken = 'error_token';

  /// 系统错误
  static const String systemError = 'system_error';

  /// 请求频率过高
  static const String tooManyRequests = 'too_many_requests';

  /// 参数类型错误
  static const String errorType = 'error_type';

  /// 用户 ID 无效
  static const String errorUid = 'error_uid';

  /// 请求数量过大
  static const String tooBigNum = 'too_big_num';

  /// 一般错误
  static const String error = 'error';

  /// 无权限
  static const String noPermission = 'no_permission';

  /// 警告/内容包含敏感词
  static const String warn = 'warn';
}

// ============================================================
// Auth 模块错误码
// ============================================================
final class AuthErrorCodes {
  const AuthErrorCodes._();

  /// 用户名/邮箱或密码错误
  static const String errorPassword = 'error_password';

  /// 密码格式错误
  static const String errorPw = 'error_pw';

  /// 两次输入的密码不一致
  static const String mismatchPw = 'mismatch_pw';

  /// 邮箱已被注册
  static const String emailExist = 'email_exist';

  /// 邮箱不存在或未注册
  static const String emailUnexist = 'email_unexist';

  /// 邮箱格式错误（非 QQ 邮箱）
  static const String errorEmail = 'error_email';

  /// QQ 邮箱格式错误（非纯数字）
  static const String errorQqEmail = 'error_qq_email';

  /// 验证码错误或已失效
  static const String errorVerificationCode = 'error_verification_code';
}

// ============================================================
// Video 模块错误码
// ============================================================
final class VideoErrorCodes {
  const VideoErrorCodes._();

  /// 视频 ID 无效
  static const String errorVid = 'error_vid';

  /// 缺少 token 参数
  static const String missingArgumentToken = 'missing_argument_token';

  /// 缺少 title 参数
  static const String missingArgumentTitle = 'missing_argument_title';

  /// 缺少 intro 参数
  static const String missingArgumentIntro = 'missing_argument_intro';

  /// 缺少 type 参数
  static const String missingArgumentType = 'missing_argument_type';

  /// 缺少 category 参数
  static const String missingArgumentCategory = 'missing_argument_category';

  /// 缺少 tag 参数
  static const String missingArgumentTag = 'missing_argument_tag';

  /// 缺少 file_mp4 参数
  static const String missingArgumentFileMp4 = 'missing_argument_file_mp4';

  /// 缺少 file_jpg 参数
  static const String missingArgumentFileJpg = 'missing_argument_file_jpg';

  /// 缺少 vid 参数
  static const String missingArgumentVid = 'missing_argument_vid';

  /// 标题超长
  static const String titleTooLong = 'title_too_long';

  /// 简介超长
  static const String introTooLong = 'intro_too_long';

  /// 标签超过 10 个
  static const String tagTooMany = 'tag_too_many';

  /// 分类非法
  static const String errorCategory = 'error_category';

  /// 标签格式不合法
  static const String errorTag = 'error_tag';

  /// 文件格式不支持
  static const String errorFile = 'error_file';

  /// 文件过大
  static const String tooBigFile = 'too_big_file';

  /// 频道不存在或已删除
  static const String channelNotFound = 'channel_not_found';

  /// 非该频道成员
  static const String notChannelMember = 'not_channel_member';

  /// 二级分区不存在
  static const String channelSectionNotFound = 'channel_section_not_found';

  /// 二级分区不属于该频道
  static const String channelSectionNotBelongToChannel =
      'channel_section_not_belong_to_channel';

  /// 视频不存在或非本人
  static const String videoNotFoundOrNotOwned = 'video_not_found_or_not_owned';
}

// ============================================================
// Following 模块错误码
// ============================================================
final class FollowingErrorCodes {
  const FollowingErrorCodes._();

  /// 关注目标用户 ID 无效
  static const String errorFollowingUid = 'error_following_uid';

  /// 关注数量超过限制（最多 888 个）
  static const String tooManyFollowings = 'too_many_followings';
}

// ============================================================
// Block 模块错误码
// ============================================================
final class BlockErrorCodes {
  const BlockErrorCodes._();

  /// 缺少 blocked_id 参数
  static const String missingBlockedId = 'Missing blocked_id parameter';

  /// 不能拉黑自己
  static const String cannotBlockYourself = 'Cannot block yourself';

  /// 用户不存在
  static const String userNotFound = 'User not found';

  /// 用户已经被拉黑
  static const String userAlreadyBlocked = 'User already blocked';

  /// 拉黑记录不存在
  static const String blockRecordNotFound = 'Block record not found';

  /// 不能解除拉黑自己
  static const String cannotUnblockYourself = 'Cannot unblock yourself';

  /// 需要 Token
  static const String tokenRequired = 'Token required';
}

// ============================================================
// Danmaku 模块错误码
// ============================================================
final class DanmakuErrorCodes {
  const DanmakuErrorCodes._();

  /// 滚幕不存在或已删除
  static const String errorDanmakuId = 'error_danmaku_id';

  /// 时间格式错误
  static const String errorTime = 'error_time';

  /// 滚幕模式错误
  static const String errorMode = 'error_mode';

  /// 颜色格式错误
  static const String errorColor = 'error_color';

  /// 字体大小格式错误
  static const String errorFontSize = 'error_font_size';

  /// 文本内容过长
  static const String textTooLong = 'text_too_long';

  /// 文本内容过短
  static const String textTooShort = 'text_too_short';

  /// render 参数过长
  static const String renderTooLong = 'render_too_long';
}

// ============================================================
// Moderation 模块错误码
// ============================================================
final class ModerationErrorCodes {
  const ModerationErrorCodes._();

  /// 不是审核员
  static const String notReviewer = 'not_reviewer';

  /// 错误的视频 ID
  static const String errorVid = 'error_vid';

  /// 错误的动态 ID
  static const String errorBid = 'error_bid';

  /// 错误的视频评论 ID
  static const String errorVcid = 'error_vcid';

  /// 错误的动态评论 ID
  static const String errorBcid = 'error_bcid';

  /// 错误的弹幕 ID
  static const String errorDanmakuId = 'error_danmaku_id';

  /// 错误的用户 ID
  static const String errorUid = 'error_uid';

  /// 不能审核自己上传的内容
  static const String cannotReviewOwnContent = 'cannot_review_own_content';

  /// 不能审核自己举报的内容
  static const String cannotReviewOwnReport = 'cannot_review_own_report';
}

// ============================================================
// Channel 模块错误码
// ============================================================
final class ChannelErrorCodes {
  const ChannelErrorCodes._();

  /// 权限不足
  static const String permissionDenied = 'permission_denied';

  /// 资源不存在
  static const String resourceNotFound = 'resource_not_found';

  /// 参数无效
  static const String invalidParameter = 'invalid_parameter';
}

// ============================================================
// Old API 模块错误码
// ============================================================
final class OldApiErrorCodes {
  const OldApiErrorCodes._();

  /// 错误的视频 ID
  static const String errorVid = 'error_vid';

  /// 错误的动态 ID
  static const String errorBid = 'error_bid';

  /// 错误的评论 ID
  static const String errorCid = 'error_cid';

  /// 错误的收藏夹 ID
  static const String errorFid = 'error_fid';

  /// 重复操作（如重复收藏）
  static const String favoriteAlready = 'favorite_already';

  /// 收藏数已满
  static const String favoriteCountFull = 'favorite_count_full';
}


