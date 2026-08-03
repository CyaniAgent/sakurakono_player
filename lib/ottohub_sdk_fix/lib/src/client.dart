import 'package:dio/dio.dart';
import 'base_api.dart';
import 'apis/auth_api.dart';
import 'apis/block_api.dart';
import 'apis/channel_api.dart';
import 'apis/danmaku_api.dart';
import 'apis/following_api.dart';
import 'apis/moderation_api.dart';
import 'apis/video_api.dart';
import 'apis/old_blog_api.dart';
import 'apis/old_comment_api.dart';
import 'apis/old_im_api.dart';
import 'apis/old_manage_api.dart';
import 'apis/old_profile_api.dart';
import 'apis/old_system_api.dart';
import 'apis/old_user_api.dart';

/// OTTOhub HTTP API 的 Flutter SDK 入口。
///
/// 持有所有 API 模块实例，通过 `I*Api` 接口暴露，便于测试替身注入。
/// 所有模块共享同一个 [Dio] 实例和 [token]。
///
/// ## 基础用法
///
/// ```dart
/// final client = OttohubClient();
///
/// // 登录后设置 token
/// final resp = await client.auth.login('user@example.com', 'pass');
/// client.token = resp.token;
///
/// // 获取随机视频
/// final videos = await client.video.getRandom(num: 10);
/// ```
///
/// ## 自定义配置
///
/// ```dart
/// final client = OttohubClient(
///   baseUrl: 'https://custom.api.com/api',
///   token: 'existing_token',
/// );
/// ```
///
/// ## 兼容模式
///
/// 通过 [BaseApiConfig] 统一配置兼容标志：
/// - [config.wrapHttpErrors]: DioException → ApiException 包装
/// - [config.relaxedResponse]: 容错响应结构
/// - [config.relaxedTypes]: 类型自动转换
///
/// ```dart
/// final client = OttohubClient(
///   config: BaseApiConfig(wrapHttpErrors: true, relaxedResponse: true),
/// );
/// ```
///
/// ## 错误处理
///
/// ```dart
/// try {
///   await client.video.getDetail(999999);
/// } on ApiException catch (e) {
///   print(e.errorCode); // 如 'error_vid'
/// }
/// ```
class OttohubClient {
  /// 创建一个 SDK 客户端。
  ///
  /// [baseUrl]: API 基础 URL，默认 `https://api.ottohub.cn/api`。
  /// [dio]: 自定义 [Dio] 实例，用于注入拦截器或自定义配置。
  /// [token]: 初始认证令牌，登录后可通过 [token] 字段设置。
  /// [config]: 兼容模式配置，详见 [BaseApiConfig]。
  OttohubClient({
    String? baseUrl,
    Dio? dio,
    String? token,
    this.config = const BaseApiConfig(),
  }) {
    final d = dio ??
        Dio(BaseOptions(
          baseUrl: baseUrl ?? 'https://api.ottohub.cn/api',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));
    this.token = token; // ignore: prefer_initializing_formals
    auth = AuthApi(d, () => this.token, config: config);
    video = VideoApi(d, () => this.token, config: config);
    following = FollowingApi(d, () => this.token, config: config);
    block = BlockApi(d, () => this.token, config: config);
    danmaku = DanmakuApi(d, () => this.token, config: config);
    channel = ChannelApi(d, () => this.token, config: config);
    moderation = ModerationApi(d, () => this.token, config: config);
    oldBlog = OldBlogApi(d, () => this.token, config: config);
    oldComment = OldCommentApi(d, () => this.token, config: config);
    oldIm = OldImApi(d, () => this.token, config: config);
    oldManage = OldManageApi(d, () => this.token, config: config);
    oldProfile = OldProfileApi(d, () => this.token, config: config);
    oldCreator = OldCreatorApi(d, () => this.token, config: config);
    oldSystem = OldSystemApi(d, () => this.token, config: config);
    oldCollection = OldCollectionApi(d, () => this.token, config: config);
    oldUser = OldUserApi(d, () => this.token, config: config);
    oldEngagement = OldEngagementApi(d, () => this.token, config: config);
  }

  /// 兼容模式配置。
  final BaseApiConfig config;

  /// 当前认证令牌。登录后设置，所有 API 模块自动注入。
  ///
  /// - GET 请求注入到 queryParameters
  /// - POST/PUT 注入到 body data
  /// - POST + FormData 注入为表单字段
  /// - DELETE 注入到 queryParameters
  String? token;

  /// 认证模块。登录、注册、验证码、密码重置、签到。
  late final IAuthApi auth;

  /// 视频模块。获取视频列表、搜索、详情、收藏/点赞、上传/更新/删除。
  late final IVideoApi video;

  /// 关注模块。关注/取关、关注/粉丝列表、动态时间线、活跃粉丝。
  late final IFollowingApi following;

  /// 屏蔽模块。屏蔽/取消屏蔽、屏蔽列表、状态查询。
  late final IBlockApi block;

  /// 弹幕模块。获取/发送/删除弹幕。
  late final IDanmakuApi danmaku;

  /// 频道模块。频道 CRUD、成员管理、内容管理、统计、搜索、公告等。
  late final IChannelApi channel;

  /// 审核模块。审核列表、审批/驳回/举报/申诉、审核日志。
  late final IModerationApi moderation;

  /// 旧版博客模块。
  late final IOldBlogApi oldBlog;

  /// 旧版评论模块。
  late final IOldCommentApi oldComment;

  /// 旧版 IM 消息模块。
  late final IOldImApi oldIm;

  /// 旧版管理模块。
  late final IOldManageApi oldManage;

  /// 旧版用户资料及创作者模块。
  late final IOldProfileApi oldProfile;

  late final IOldCreatorApi oldCreator;

  /// 旧版系统模块。版本号、幻灯片、开屏动画、法律文档。
  late final IOldSystemApi oldSystem;

  /// 旧版收藏模块。
  late final IOldCollectionApi oldCollection;

  /// 旧版用户模块。
  late final IOldUserApi oldUser;

  /// 旧版互动模块。
  late final IOldEngagementApi oldEngagement;
}
