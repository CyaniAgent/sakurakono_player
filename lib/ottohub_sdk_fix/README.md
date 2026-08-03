# ottohub_sdk_dart

OTTOhub HTTP API 的 Flutter SDK 封装。提供类型安全的 Dart API 接口，支持所有核心业务模块。

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  ottohub_sdk_dart: ^0.0.1
```

## 功能

| 模块 | 类 | 接口 | 方法数 |
|------|------|------|--------|
| 认证 | `AuthApi` | `IAuthApi` | 5 |
| 视频 | `VideoApi` | `IVideoApi` | 17 |
| 关注 | `FollowingApi` | `IFollowingApi` | 7 |
| 屏蔽 | `BlockApi` | `IBlockApi` | 5 |
| 弹幕 | `DanmakuApi` | `IDanmakuApi` | 3 |
| 频道 | `ChannelApi` | `IChannelApi` | 40 |
| 审核 | `ModerationApi` | `IModerationApi` | 35 |
| 旧版 API | 10 个模块 | `IOld*Api` | ~79 |

## 快速开始

```dart
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

void main() async {
  final client = OttohubClient();

  // 登录后设置 token
  final response = await client.auth.login('user@example.com', 'password123');
  client.token = response.token;

  // 获取随机视频列表
  final videos = await client.video.getRandom(num: 10);

  // 获取视频详情
  final detail = await client.video.getDetail(vid: 42);
}
```

## 错误处理

SDK 可能抛出两类异常：

```dart
import 'package:dio/dio.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

try {
  final result = await client.auth.login('wrong', 'credentials');
} on ApiException catch (e) {
  // API 级错误（status == "error"）
  print('错误码: ${e.errorCode}');  // 如 "error_token", "missing_argument"
} on DioException catch (e) {
  // HTTP/网络级错误（4xx, 5xx, 超时）
  print('HTTP ${e.response?.statusCode}: ${e.message}');
}
```

常见 `ApiException` 错误码：`missing_argument`、`error_token`、`system_error`、`too_many_requests`。

## Token 管理

```dart
// 登录后设置
client.token = response.token;

// 清除 token（登出）
client.token = null;

// 自定义存储（如 shared_preferences）
final prefs = await SharedPreferences.getInstance();
client.token = prefs.getString('auth_token');
```

Token 自动注入规则：
- GET / DELETE 请求 → `queryParameters`
- POST / PUT 请求 → `data` 字段
- POST + FormData → `fields`

## 自定义 Dio

通过 `OttohubClient.baseOptions` 可自定义 Dio 配置，如添加拦截器或更改超时：

```dart
final client = OttohubClient(
  baseOptions: BaseOptions(
    baseUrl: 'https://custom-api.example.com/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);

// 添加自定义拦截器（如日志输出）
client.dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

## 完整调用示例

```dart
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

Future<void> main() async {
  final client = OttohubClient();

  // ── 认证 ──
  final loginResp = await client.auth.login('user@example.com', 'password123');
  client.token = loginResp.token;

  // 注册
  await client.auth.register(
    email: 'new@example.com',
    verificationCode: '123456',
    password: 'pass123',
    confirmPassword: 'pass123',
  );

  // 每日签到
  await client.auth.signIn();

  // ── 视频 ──
  final randomVideos = await client.video.getRandom(num: 5);
  for (final v in randomVideos.videoList) {
    print('${v.vid}: ${v.title} (${v.viewCount} 播放)');
  }

  final detail = await client.video.getDetail(42);
  print('分类: ${detail.category}, 点赞: ${detail.ifLike == 1}');

  final searchResult = await client.video.search(searchTerm: 'flutter', num: 10);
  await client.video.toggleLike(42);          // 点赞/取消
  await client.video.toggleFavorite(42);      // 收藏/取消
  await client.video.saveWatchHistory(42, 30);// 保存进度

  // ── 关注 ──
  final result = await client.following.toggleFollow(123);
  final status = await client.following.getStatus(123);
  final timeline = await client.following.getTimeline();
  final activeFans = await client.following.getActiveFollowers(123);

  // ── 屏蔽 ──
  await client.block.blockUser(456, reason: 'spam');
  final blockList = await client.block.getBlockList(page: 1);
  final blockStatus = await client.block.getBlockStatus(456);
  await client.block.unblockUser(456);

  // ── 弹幕 ──
  final danmakuList = await client.danmaku.getDanmaku(42);
  await client.danmaku.sendDanmaku(42, text: '好评', time: 5.5);

  // ── 频道 ──
  final channel = await client.channel.getChannelDetail(1);
  print('频道: ${channel.channelTitle}, 成员: ${channel.memberCount}');

  await client.channel.followChannel(1);
  final memberList = await client.channel.getMemberList(1);
  final sections = await client.channel.getSections(1);

  // ── 审核（管理员） ──
  final unread = await client.moderation.getUnreadCount();
  final logs = await client.moderation.getLogs(offset: 0, num: 10);
  await client.moderation.approveVideo(42);

  // ── 旧版 API ──
  final userDetail = await client.oldUser.getUserDetail(123);
  final profile = await client.oldProfile.getUserProfile(123);

  // ── 错误处理 ──
  try {
    await client.video.getDetail(999999);
  } on ApiException catch (e) {
    print('API 错误: ${e.errorCode}');
  } on DioException catch (e) {
    print('网络错误: ${e.message}');
  }
}
```

## 架构

```
OttohubClient
 ├── IAuthApi          (认证)
 ├── IVideoApi         (视频)
 ├── IFollowingApi     (关注)
 ├── IBlockApi         (屏蔽)
 ├── IDanmakuApi       (弹幕)
 ├── IChannelApi       (频道)
 ├── IModerationApi    (审核)
 ├── IOldBlogApi       (博客 - 旧版)
 ├── IOldCommentApi    (评论 - 旧版)
 ├── IOldImApi         (IM - 旧版)
 ├── IOldManageApi     (管理 - 旧版)
 ├── IOldProfileApi    (资料 - 旧版)
 ├── IOldCreatorApi    (创作者 - 旧版)
 ├── IOldSystemApi     (系统 - 旧版)
 ├── IOldCollectionApi (收藏 - 旧版)
 ├── IOldUserApi       (用户 - 旧版)
 └── IOldEngagementApi (互动 - 旧版)
```

所有模块均基于 `BaseApi`，提供统一的：
- Token 自动注入（GET 查参 / POST 请求体 / FormData 字段 / DELETE 查参）
- 响应校验：`status == "error"` 时抛出 `ApiException`

API 接口全部定义在抽象接口中（如 `IVideoApi`），便于测试时 Mock。

## 依赖

- [Dio](https://pub.dev/packages/dio) ^5.10.0 — HTTP 客户端
- [json_annotation](https://pub.dev/packages/json_annotation) ^4.12.0 — 序列化

## 许可

MIT License

