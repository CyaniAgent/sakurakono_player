# Group 2: 数据层重构 — SPES-010 ~ SPES-013

## 现状分析

| 项目 | 结论 |
|------|------|
| HTTP 层 | 20 个 `abstract final class XxxHttp` 静态类（VideoHttp, UserHttp, SearchHttp...） |
| gRPC 层 | 直接调用 protobuf 生成的客户端，零抽象 |
| 控制器 | 直接 import 具体的 XxxHttp 类，紧耦合 |
| Core 接口 | 现有 Player/Account 接口，**无 Repository 接口** |
| 方法数量 | ~300+ 个 HTTP 方法，~50+ 控制器 |

## 策略

**渐进式，从核心业务开始，不一次做全部 20 个 Repository。**

优先做 5 个核心领域：

| 优先级 | Repository | HTTP 类 | 影响的控制器数 |
|--------|-----------|---------|---------------|
| P0 | **VideoRepository** | VideoHttp | ~10 |
| P0 | **AuthRepository** | LoginHttp | ~8 |
| P1 | **UserRepository** | UserHttp + MemberHttp | ~12 |
| P1 | **SearchRepository** | SearchHttp | ~6 |
| P2 | **FavRepository** | FavHttp | ~4 |

---

## SPES-010: Repository 接口定义

**目标**: 在 `lib/core/repository/` 中定义 5 个核心 Repository 接口。

### 新增文件

```
lib/core/repository/
├── video_repository.dart    # VideoRepository
├── auth_repository.dart     # AuthRepository
├── user_repository.dart     # UserRepository
├── search_repository.dart   # SearchRepository
└── fav_repository.dart      # FavRepository
```

### 核心接口示例 (VideoRepository)

```dart
abstract class VideoRepository {
  Future<LoadingState<VideoDetailData>> videoDetail({
    required String bvid,
    int? aid,
  });
  Future<LoadingState<VideoPlayInfo>> videoPlayUrl({
    required String bvid,
    required int cid,
    int qn = 0,
  });
  Future<LoadingState<List<VideoDetailPage>>> videoPages({
    required String bvid,
    int? aid,
  });
  // ...更多方法
}
```

### 产出

- 5 个接口文件，覆盖 ~80 个最常用的 HTTP 方法
- 使用 `lib/core/result/loading_state.dart`（已有）
- 使用 `package:skf/core/models/` 中的通用 Model

### flutter analyze
```bash
# 接口文件本身不调具体实现 → 0 errors
```

---

## SPES-011: B站 Repository 实现

**目标**: 在 `adapters/bilibili/repository/` 中实现上述 5 个接口。

### 新增文件

```
lib/adapters/bilibili/repository/
├── bili_video_repository.dart
├── bili_auth_repository.dart
├── bili_user_repository.dart
├── bili_search_repository.dart
└── bili_fav_repository.dart
```

### 实现模式

每个实现类包装对应的 XxxHttp 静态调用：

```dart
class BiliVideoRepository implements VideoRepository {
  @override
  Future<LoadingState<VideoDetailData>> videoDetail({
    required String bvid,
    int? aid,
  }) {
    return VideoHttp.videoDetail(bvid: bvid, aid: aid);
  }
}
```

### 注册到 Bridge

在 `BiliBridge.register()` 中添加：

```dart
Get.lazyPut<VideoRepository>(BiliVideoRepository.new);
Get.lazyPut<AuthRepository>(BiliAuthRepository.new);
// ...
```

### flutter analyze
```bash
# 实现类"implements"接口 → 编译器确保方法签名匹配 → 0 errors
```

---

## SPES-012: 首轮控制器注入 (P0 目标)

**目标**: 将 Video 和 Auth 的 3-5 个关键控制器改为依赖 Repository 接口。

### 改造目标

| 控制器 | 当前模式 | 改造后 |
|--------|---------|--------|
| `video/controller.dart` | 直接 `VideoHttp.videoDetail()` | `Get.find<VideoRepository>().videoDetail()` |
| `login/controller.dart` | 直接 `LoginHttp.loginByxxx()` | `Get.find<AuthRepository>().login()` |
| `home/controller.dart` | 直接调用多个 HTTP | 重构为 Repository 调用 |

### 验证标准

- 改造后的控制器不再直接 import XxxHttp 类
- 改造后的控制器通过构造函数或 `Get.find` 获取 Repository
- flutter analyze 0 errors

---

## SPES-013: gRPC 抽象

**目标**: gRPC 调用（`adapters/bilibili/grpc/`）也要走抽象，不直接暴露 protobuf 客户端。

### 现状

`lib/adapters/bilibili/grpc/` 中有这些封装：
- `grpc_req.dart` — gRPC 请求封装
- `dm.dart` — 弹幕服务
- `dyn.dart` — 动态服务
- `reply.dart` — 回复服务
- `im.dart` — 私信服务
- `space.dart` — 空间服务
- `audio.dart` — 音频服务
- `url.dart` — URL 服务
- `view.dart` — 视频流服务

### 方案

gRPC 抽象应该直接融入对应的 Repository 接口中，不独立创建 gRPC 抽象层。例如：
- `VideoRepository.videoPlayUrl()` 内部可调用 gRPC 或 HTTP，调用方无需关心
- `ReplyRepository` 封装 gRPC reply + HTTP reply

---

## 产出清单

| SPES | 新增文件 | 修改文件 | 预估 |
|------|---------|---------|------|
| 010 | 5 (接口) | 0 | 2 天 |
| 011 | 5 (实现) | 1 (bridge) | 3 天 |
| 012 | 0 | 5 (控制器) | 5 天 |
| 013 | 0 | 融入 010-011 | 0 (不独立) |

总计: +10 文件，~6 文件修改，~10 天
