# SKF 架构指南（开发者版）

> 面向新贡献者与适配器开发者的架构文档。所有路径、数字与模式均来自本仓库的 AGENTS.md 知识库（root + lib/core + lib/adapters/bilibili + lib/adapters/ottohub + lib/common + lib/utils）以及实际代码。修改代码时请让本文档与 AGENTS.md 保持一致。

---

## 1. 总览

**SakuraKono Player Framework (SKF)** 是一个基于 Flutter 的通用视频播放器框架。`pubspec.yaml` 中 `name: skf`，Android 包名为 `com.sakurakono.app`。SKF 不是一个单用途 App，而是一套「核心契约 + 平台适配器」的框架：核心层定义播放器应用所需的全部抽象接口，适配器层提供某一视频平台的具体实现。

当前支持两个适配器：

| 适配器 | 状态 | 仓库覆盖 | 说明 |
|--------|------|---------|------|
| Bilibili（`lib/adapters/bilibili/`） | 完整 | 24/24 | 生产环境默认；全部功能 |
| OttoHub（`lib/adapters/ottohub/`） | 进行中 | 24/24 已注册（14 real + 2 partial + 8 stubs） | 测试/验证架构可行性；生产仅 Bilibili |

**适配器在编译期选择**：`flutter run --dart-define=ADAPTER=bilibili`（默认）或 `--dart-define=ADAPTER=ottohub`。启动时两个适配器都会注册进 `AdapterRegistry`，由 `ADAPTER` 宏决定激活哪一个。因此不存在运行时插件加载、也没有运行时换平台的能力；换适配器必须重新编译。

其余关键事实：

- 所有 `package:` 导入统一使用 `skf` 前缀（`package:skf/...`），禁止相对导入。
- `lib/core/` 与 `lib/common/` 对 `lib/adapters/` 的导入数为 **零**（grep 可验证）。
- 技术栈：Flutter 3.47.0 / Dart 3.13.0（`.fvmrc` 与 `pubspec.yaml` 已锁定），GetX 状态管理，media_kit 播放内核。

---

## 2. 分层架构

```
lib/
├── core/                      # 契约层：抽象接口，零 adapter 依赖
│   ├── adapter/               # AppAdapter 接口 + AdapterRegistry
│   ├── account/               # AccountProvider (GetxService) + AccountMixin
│   ├── models/                # ~30 个 Core* 类型（video, user, live, fav, msg, …）
│   ├── repository/            # 24 个 Repository 接口（Video, User, Auth, Danmaku, …）
│   ├── result/                # LoadingState<T> 密封类（唯一统一版本）
│   └── utils/                 # pair, subtitle_utils, image_action_registry
├── adapters/
│   ├── bilibili/              # B站 适配器（生产）
│   │   ├── bili_adapter.dart  # BiliAdapter implements AppAdapter
│   │   ├── bridge.dart        # 唯一入口：initHive / register / registerRoutes
│   │   ├── repository/        # 24 个 Bili*Repository（实现 core 接口）
│   │   ├── pages/             # 全部 B站 UI（441 文件 / 114 页目录 / 161 view.dart）
│   │   ├── http/              # Dio + HTTP/2 适配器（Request 单例 + 25 端点文件）
│   │   ├── grpc/              # Bilibili gRPC（8 手写 + 99 生成，生成物不分析）
│   │   ├── utils/             # model_converters.dart 等转换工具
│   │   ├── models/ + models_new/   # 双模型树（见 3.5）
│   │   ├── services/          # account provider、download、audio、logger
│   │   ├── plugin/pl_player/  # media_kit 播放器 UI 层
│   │   └── common/ + tcp/     # 适配器内共享组件 + tcp live
│   └── ottohub/               # OttoHub 适配器（实验，DI 覆盖层）
│       ├── bridge.dart        # OttoAdapter implements AppAdapter
│       ├── repository/        # 24 个 Otto*Repository（14 real + 2 partial + 8 stubs）
│       └── services/          # OttoAccountProvider
├── ottohub_sdk_fix/           # 本地 vendored ottohub_sdk_dart（path override，不分析）
├── common/                    # 共享 UI 组件（128 文件，零 adapter 导入）
├── utils/                     # 存储（hive_ce）、路径、平台、主题（50 文件）
├── router/app_pages.dart      # GetX 路由：使用 AdapterRegistry.active.routes
├── scripts/                   # patch.ps1 / build.ps1 / 18 个 Flutter SDK .patch
├── grpc/bilibili/             # 独立 gRPC 生成代码（不分析）
├── build_config.dart          # 版本注入读取（skf.* via fromEnvironment）
└── main.dart                  # 入口：initHive → AdapterRegistry → run App
```

### 依赖方向（不可逆）

- `core` 只向上依赖 Flutter/GetX 等三方库，**不依赖任何 adapter、common、utils**。core 的 utils 只能用自己的 `core/utils/pair.dart`。
- `common`（共享组件）零 adapter 导入；`common ⇄ utils` 双向耦合，两者都导入 core。约定方向是 common 多、utils 少（utils 导入 common 仅 4 处）。
- `utils` 不导入 adapter；`utils → common` 属罕见方向，保持最少。
- 页面层（adapter 内）通过 `Get.find<Repository>()` 访问数据，**不直接发 HTTP**。

---

## 3. 核心概念

### 3.1 AppAdapter + AdapterRegistry：适配器的两面

**AppAdapter**（`lib/core/adapter/app_adapter.dart`）是每个适配器必须实现的最小接口，仅 4 个成员：

```dart
abstract class AppAdapter {
  String get name;                                    // 'bilibili' / 'ottohub'
  Future<void> registerDependencies();                // DI 绑定：Get.lazyPut 全部仓库
  List<GetPage> get routes;                           // 路由表（复用 B站 页面表即可）
  String processImageUrl(String originalUrl, {int? quality}); // 图片 URL 处理
}
```

**AdapterRegistry**（`lib/core/adapter/adapter_registry.dart`）提供 `register()`、`activate(name)`、`active` 三个入口。main.dart 启动时先把两个适配器都注册进去，再由 `ADAPTER` 宏选择激活哪一个。

### 3.2 main.dart 启动链

启动顺序是硬约束，打乱会在启动期崩溃：

```
main()
├─ ScaledWidgetsFlutterBinding.ensureInitialized()
├─ MediaKit.ensureInitialized()
├─ _initAppPath()                     // 应用支持目录
├─ BiliBridge.initHive()              // ① 注册 7 个 Hive TypeAdapter，必须先于开箱
├─ GStorage.init()                    // ② 并行打开 7 个 Hive box；失败则退出
├─ Accounts.init()                    // ③ 账户 box（可能已被打开，须容错）
├─ 并行：_initDownPath / _initTmpPath / CacheManager.ensureInitialized()
├─ AdapterRegistry.register(BiliAdapter())   // 双适配器都注册
├─ AdapterRegistry.register(OttoAdapter())
├─ AdapterRegistry.activate(          // 按 ADAPTER 宏激活，默认 'bilibili'
│     String.fromEnvironment('ADAPTER', defaultValue: 'bilibili'))
└─ runApp(MyApp)                      // GetMaterialApp，getPages: Routes.getPages
```

存储初始化的顺序红线：**BiliBridge.initHive（TypeAdapter 注册）→ GStorage.init → Accounts.init**。三者次序不可交换，任何违规都会在启动期崩溃。

### 3.3 24 个 Repository 接口 + LoadingState<T>

**core 侧**：`lib/core/repository/` 下有 24 个接口，每个领域一个，命名 `<Domain>Repository`（如 `AuthRepository`、`VideoRepository`、`DanmakuRepository`）。每个方法返回 `Future<LoadingState<T>>`。

**适配器侧**：Bilibili 提供 24 个 `Bili*Repository`，OttoHub 提供 24 个 `Otto*Repository`，通过 `Get.lazyPut<CoreRepo>(() => BiliXxxRepository())` 绑定到 core 接口。页面只认 core 接口类型：

```dart
final repo = Get.find<VideoRepository>();   // 页面从不关心实际是 Bili 还是 Otto
```

**LoadingState<T>**（`lib/core/result/loading_state.dart`）是统一的异步结果密封类：

```dart
sealed class LoadingState<T> {
  LoadingState.loading();      // 加载中
  Success<T>(response);        // 成功，携带数据
  Error(errMsg, {code});       // 失败，携带消息与可选错误码
  Future<void> toast();        // 弹 SmartDialog 错误提示
}
```

约定：Repository 参数已全部类型化为 `String`/`int`（媒体/内容 ID 用 String，用户 ID 用 int），**禁止回归 `Object`/`dynamic`**（SPES-014）。core 的模型是纯数据类（无 Hive 注解），需要持久化的类型放在适配器内（`bilibili/models`）。

### 3.4 统一播放入口（替代旧的插件式播放）

**动态插件加载在 Flutter AOT 下不可行**，因此播放的统一入口是设置页的「播放链接」：

```
设置页「播放链接」（pages/setting/play_input_dialog.dart）
   │
   ▼
classifyPlayInput(input)          // lib/adapters/bilibili/utils/play_input.dart，纯函数
   │
   ├─ B站 URL / BV / av ─────────► PiliScheme.routePushFromUrl   （utils/app_scheme.dart）
   └─ OttoHub 纯数字 ID ─────────► PageUtils.toVideoPage          （utils/page_utils.dart）
```

`classifyPlayInput` 是纯函数（trim 后判定），分派时必须使用同一 trimmed 值；`PiliScheme.routePushFromUrl` 是 async 且 b23.tv 需要网络 302，绝不能放进纯函数。

### 3.5 B站 播放链路与双模型树

**播放链路**：`PageUtils.toVideoPage` → 路由 `/videoV` → `PlPlayerController`（`plugin/pl_player/controller.dart`，media_kit 的包装层，带 `BlockConfigMixin`）。OttoHub 没有自己的播放器，播放走同一套 B站 UI/播放器。

**双模型树**（Bilibili 特有）：

- `models/`（87 文件）：跨功能共享 + Hive 持久化类型，`@HiveType` + `.g.dart` 生成。
- `models_new/`（366 文件）：端点专属纯 fromJson DTO，按 `<feature>/<endpoint>/data|result|item.dart` 组织，无 Hive。

新端点 DTO 优先放 `models_new/`；`models/` 只放共享/持久化类型。

**Core↔adapter 转换**：core 与 adapter 类型是「字段相同但类不同」的独立类。所有已知转换集中在 `lib/adapters/bilibili/utils/model_converters.dart`（约 1446 行，`abstract final class ModelConverters`，约 40 个公开 static + 约 60 个私有 `_toCore*`）。转换手法是：用 core 字段拼 `Map<String, dynamic>` 再走 adapter 的 `fromJson()`，即 JSON 往返。**`as dynamic` 被全面禁止**，现有强制转换都是编译期可见的类型恒等转换。

---

## 4. 适配器开发指南（怎么写一个新适配器）

OttoHub 是一个可参考的完整样例：26 个文件、无自有页面、纯 DI 覆盖层，把 OttoHub 的仓库/账户实现注入到同一套 B站 UI 下。

### 4.1 骨架

```dart
class NewAdapter implements AppAdapter {
  String get name => 'newadapter';

  @override
  Future<void> registerDependencies() {
    // 1. 初始化你的 HTTP/SDK 客户端
    // 2. 为 24 个 core 接口逐一 Get.lazyPut：
    Get.lazyPut<VideoRepository>(() => NewVideoRepository(client));
    Get.lazyPut<AuthRepository>(() => NewAuthRepository(client));
    // ...（全部 24 个，或暂时用 stub 顶替）
    // 3. AccountProvider 必须注册实现（core 要求 GetxService）：
    Get.lazyPut<AccountProvider>(() => NewAccountProvider());
  }

  @override
  List<GetPage> get routes => BiliBridge.registerRoutes(); // 复用整张 B站 页面表

  @override
  String processImageUrl(String originalUrl, {int? quality}) {
    return originalUrl; // 或按平台规则改写图片 URL
  }
}
```

### 4.2 注册与激活

在 `lib/main.dart` 启动链中把新适配器注册进 `AdapterRegistry`：

```dart
AdapterRegistry.register(BiliAdapter());
AdapterRegistry.register(OttoAdapter());
AdapterRegistry.register(NewAdapter());
```

激活仍由 `--dart-define=ADAPTER=<name>` 控制。**生产环境只启用一个适配器（Bilibili）**；多适配器并存（OttoHub）仅为验证架构可行性。

### 4.3 三条铁律

1. **24 个仓库都要注册**，即使某些方法只能返回 `Error('not_implemented')`。OttoHub 的 8 个 stub 仓库就是干这个的：stub 返回 `Error` 不是 bug，而是防止 `Get.find<>()` 崩溃的契约。
2. **AccountProvider 必须实现**：`lib/core/account/account_provider.dart` 是抽象类且继承 `GetxService`，适配器必须注册一个实现（OttoHub 的 `services/otto_account_provider.dart` 是 Hive 支撑的参考实现）。
3. **复用 B站 路由表**：`routes => BiliBridge.registerRoutes()` 直接获得全部页面；`/` 首页在 `lib/router/app_pages.dart` 中硬编码为 B站 `MainApp`。代价是适配器会耦合 B站 内部细节（OttoHub 已接受此耦合），新耦合要尽量少。

### 4.4 常见适配器内差异点

- **HTTP 栈**：B站 用自定义 `Request` 单例（Dio + dio_http2_adapter + 自解码 brotli/gzip + Retry/Log/AccountManager 拦截器）；OttoHub 用 vendored `OttohubClient`（约 17 个 API 模块）。新适配器自选。
- **仓库方法签名**：保持与 core 接口一致，参数类型 `String`/`int`，返回 `Future<LoadingState<T>>`。
- **转换层**：OttoHub 表面小，在仓库内联转换；B站 集中到 `model_converters.dart`。

---

## 5. 技术约束（重要）

### 5.1 动态插件加载在 Flutter AOT 下不可行

- `Isolate.spawnUri` 不支持 AOT；
- `dart:mirrors` 在 AOT 下禁用；
- dart_eval 运行时成本高（参见 AppFlowy 2023 的实践结论）。

因此 SKF **不支持运行时动态加载平台插件**。远期愿景是 JS/LUA 脚本引擎（quickjs 一类），**尚未实现**。当前替代物是 3.4 节的统一播放入口 + 编译期选适配器。

### 5.2 分层纯净性（grep 可验证）

- `core` 与 `common` 对 `lib/adapters/` 的导入数为 **零**。组件只有在不依赖 adapter 数据时才可能进入 `common`；需要 adapter 数据就留在适配器内，或通过构造参数/接口（如 `ImageActionDelegate`）注入。
- `always_use_package_imports` / `avoid_relative_lib_imports`：一切导入写 `package:skf/...`，禁止相对导入。
- `as dynamic` 被禁止（SPES-014），转换走 `ModelConverters`。

### 5.3 生成文件与排除区

- **不要编辑生成文件**：`*.pb.dart`、`models/*.g.dart`、`lib/utils/android/bindings.g.dart`。
- 分析排除区：`lib/grpc/bilibili/**`、`lib/adapters/bilibili/grpc/**`、`lib/ottohub_sdk_fix/**`（vendored SDK 自带独立分析配置）。
- OttoHub SDK 的修复改 `lib/ottohub_sdk_fix/`，**不要改 pub.dev**。

### 5.4 OttoHub stub 反造假契约

stub 方法 `=> Error(const ApiException('not_implemented'))`，看起来「已实现」但对 `Get.find<>()` 无害。排查「某个 OttoHub 功能点了没反应」时先确认该仓库是否在 8 个 stub 之列，那不是 bug。

### 5.5 Hive 初始化顺序

`BiliBridge.initHive()`（TypeAdapter 注册）必须先于 `GStorage.init()`（开箱），`Accounts.init()` 最后。任何违反都会在启动期崩溃。

### 5.6 结构式功能移除（无编译开关）

路由无条件注册。移除一个功能 = 三步：

1. 删除 `lib/adapters/bilibili/bridge.dart` `registerRoutes()` 中对应 GetPage 行；
2. 删除对应 `pages/<feature>/` 目录；
3. 删除仅该功能使用的 repository 注册/依赖。

---

## 6. 测试体系

**共 232 个测试**，分解如下：

| 组 | 数量 | 说明 |
|----|------|------|
| `test/repository/`（24 个信封测试） | 72 | 每个 core 仓库 3 个（happy + error + edge），覆盖全部 24 个接口，无缺口 |
| `test/num_utils_test.dart` | 7 | 数字工具 |
| `test/adapters/bilibili/` | 28 | bili_follow 7 + bili_video 5 + model_converters 3 + play_input 13 |
| `test/adapters/ottohub/` | 121 | 分布在 14 个 Otto*Repository 测试文件 |
| `test/helpers/fake_http_adapter_test.dart` | 4 | FakeHttpAdapter 自测 |
| **合计** | **232** | |

关键约定：

- **mockito + build_runner**：`@GenerateMocks([<Core>Repository])` 生成 `*.mocks.dart`（已 gitignore，用 `dart run build_runner build` 重新生成）。mock 目标是 **core 接口**，不是 Bili/Otto 前缀类型。泛型 `LoadingState<T>` 返回需要 `provideDummy<LoadingState<...>>(...)`，否则 build_runner 失败。
- **两类测试分工**：24 个信封测试只验证 `LoadingState` 契约的形状，不触碰适配器实现；`test/adapters/<adapter>/` 的测试真正跑适配器代码，用 fixtures + `FakeHttpAdapter`（`test/helpers/`）+ bili_bootstrap。
- **现状缺口**：没有 widget 测试，也没有集成测试。CI 里也没有 `flutter test` job（测试只在本地跑）。贡献者可以补这些。

常用命令：

| 动作 | 命令 |
|------|------|
| 分析（Bilibili，必须 0 errors 0 warnings） | `flutter analyze --dart-define=ADAPTER=bilibili` |
| 分析（OttoHub） | `flutter analyze --dart-define=ADAPTER=ottohub` |
| 跑测试 | `flutter test` |
| 生成 mock / 代码 | `dart run build_runner build --delete-conflicting-outputs` |
| 自动修 lint | `dart fix --apply` |
| 安装依赖 | `flutter pub get`（不是 `dart pub get`） |

---

## 7. 常见开发任务定位表（Where to look）

| 任务 | 位置 |
|------|------|
| 新增 B站 API 端点 | `lib/adapters/bilibili/http/<domain>.dart` + `repository/bili_<domain>_repository.dart` |
| 新页面 | `pages/<page>/{view,controller}.dart` + 在 `bridge.registerRoutes()` 注册 |
| Core↔adapter 类型转换 | `lib/adapters/bilibili/utils/model_converters.dart` |
| 播放器行为 | `lib/adapters/bilibili/plugin/pl_player/`（media_kit 包装） |
| B站 gRPC API | `lib/adapters/bilibili/grpc/`（只改手写 wrapper，生成物不动） |
| 定义新的 core 功能接口 | `lib/core/repository/<domain>_repository.dart` |
| 读写设置 | `Pref.<name>`（`lib/utils/storage_pref.dart`；新 key 先加 `storage_key.dart`） |
| 存储初始化 / box | `lib/utils/storage.dart` |
| 路径 / 下载命名 | `lib/utils/path_utils.dart` |
| 主题定制 | `lib/utils/theme_utils.dart` + `lib/common/style.dart` |
| 构建 / 版本信息 | `lib/build_config.dart`（经 `lib/core/app_meta.dart` 的 `skf` 前缀） |
| 实现缺失的 OttoHub 仓库 | `lib/adapters/ottohub/repository/otto_<domain>_repository.dart` + 在 bridge.dart 注册并移出 stub 列表 |
| OttoHub 账户 / 令牌 | `lib/adapters/ottohub/services/otto_account_provider.dart` |
| OttoHub SDK 行为 | `lib/ottohub_sdk_fix/`（vendored，不分析） |
| 加载 / 错误 UI | `lib/common/widgets/loading_widget/` + `loading_widget.dart` |
| 视频进度 / 控制条 | `lib/common/widgets/progress_bar/` + `player_bar.dart` |
| 图片网格 / 查看器 | `lib/common/widgets/image_grid/`、`image_viewer/`、`image/` |
| 列表占位骨架 | `lib/common/skeleton/` |
| 共享样式 token | `lib/common/style.dart` |

---

## 附：知识库层级

本指南是 AGENTS.md 知识库的浓缩。更细的子树事实（HTTP 栈细节、页面模式、存储 box 清单、双向耦合位置等）请按层级查阅：

```
AGENTS.md                          # 根：身份、SDK、lint、构建发布、依赖、测试总览
├── lib/core/AGENTS.md             # 契约层：AppAdapter、LoadingState、24 仓库接口、反模式
├── lib/adapters/bilibili/AGENTS.md  # B站 内部：bridge、HTTP 栈、页面模式、双模型树、转换器
├── lib/adapters/ottohub/AGENTS.md   # OttoHub：DI 覆盖层、stub 契约、vendored SDK
├── lib/common/AGENTS.md           # 共享组件：关键控件、dot-shorthand 约定、禁 adapter 导入
└── lib/utils/AGENTS.md            # 存储初始化顺序、Pref、主题、版本管线
```
