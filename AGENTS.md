# AGENTS.md — SakuraKono Player / SKF

## Identity

- **SakuraKono Player Framework (SKF)**: 通用视频播放器 Flutter 框架模板。`pubspec.yaml name: skf`。Android package: `com.sakurakono.app`。
- **适配器**: OttoHub(`lib/adapters/ottohub/`,唯一真实适配器,数据层大部分真实现)+ ExampleAdapter(`lib/adapters/example/`,新适配器开发骨架)。
- 历史上的 Bilibili 适配器已于 2026-09-16 删除(快照 commit `bb7d917`);其"能力接口"以中立形状保留在 `lib/core/contract/player/`(片段跳过/系列/合集/笔记/听音频/互动视频/字幕/高能/下载)。
- 所有 `package:` imports 使用 `skf` 前缀;`lib/core`、`lib/pages`、`lib/common`、`lib/player` **零适配器 import**(grepped)。

## Current Phase

- **去 B 站化重构完成(2026-09-16)**:bilibili 适配器 982 文件删除;标准抽象接口层(`lib/core/contract/`)落地;OttoHub 为唯一真实适配器;存储键/B 站依赖已清理。
- **路由**:纯 go_router(`MaterialApp.router`,`AppRouter.create`;门面 `AppNavigator`:`to/toNamed/back/parametersOf/arguments`)。路由表由激活适配器提供:`OttoBridge.routes`(28 条指向框架页)。
- **DI/状态**:Riverpod 全局 `appContainer`(`lib/core/container/app_container.dart`,非 widget 代码用 `appRead(provider)`)+ `ProviderContainer(overrides: adapterOverrides)`。
- **能力降级模式(核心设计)**:可选播放器能力(片段跳过/系列/合集/笔记/听音频/互动/字幕/高能/下载/播放源)定义为 `core/contract/player/` 下的独立接口;`VideoHost with DefaultPlayerCapabilities` 提供 no-op 默认(`supported=false`),适配器覆写 getter 返回自身即接入;页面对 null/不支持自动降级隐藏。**禁止 pages import 任何适配器**。
- **Controller 模式**:`CommonControllerRiverpod`/`CommonListControllerRiverpod`(ChangeNotifier);页面 `ListenableBuilder`。注册表模式:`Map<String, T> xxxRegistry` + `Provider.family`(member 页)。
- **播放入口**:设置页「播放链接」→ `SettingHost.openVideoById`(适配器自实现跳转)。
- **已知边界(待接入)**:登录 UI 已有框架页(`/loginPage`,OttoHub 账密直传)+ 账号状态接线(启动恢复缓存/登录后同步 Riverpod)。视频页(播放器/弹幕/简介/评论/相关面板)、用户页(投稿/动态 tab)、动态页(博客流/博客详情 `/blogDetail`)均已接入。SDK 旧路由已按 2026-09 服务端 REST 迁移(comment/video/user/blog/danmaku;`/user/{uid}`、`/blog/latest`、`/blog/users/{uid}/blogs`、`/blog/{bid}/detail`、`/comment/videos/{vid}` 等)。

## SDK & env

- **Flutter 3.47.0 / Dart 3.13.0** — `.fvmrc` 与 pubspec 锁定。FVM 时用 `fvm flutter`。
- Dart MCP server 配置于 `opencode.jsonc`(`dart mcp-server`)。

## Linting & formatting

`analysis_options.yaml` extends `flutter_lints/flutter.yaml`,42 条显式规则(与删除前一致)。关键:
- `always_use_package_imports` — 所有 import 用 `package:skf/...`。
- `prefer_const_*`、`unnecessary_late`、`avoid_print`、`cascade_invocations`、`sized_box_for_whitespace` 等。
- `formatter: trailing_commas: preserve` — 不要增删尾逗号。
- `flutter analyze` 必须 **0 错误 0 警告**(info 可容忍)。

## Architecture

```
lib/
├── core/                       # 中立抽象层(零适配器依赖)
│   ├── contract/player/        # ★ 标准播放器契约:VideoPlayerHost + 10 能力接口
│   │                           #   + PlayerCapabilities/DefaultPlayerCapabilities
│   ├── adapter/                # AppAdapter + AdapterRegistry
│   ├── account/                # AccountProvider (ChangeNotifier)
│   ├── models/                 # Core* 模型(member_types 深度净化为后续路线)
│   ├── repository/             # 18 个 repository 接口(黑名单并入 follow 前身保留)
│   ├── utils/ result/ app_meta.dart
├── adapters/
│   ├── ottohub/                # 唯一真实适配器(repo 大半真实现 + Host 桩)
│   │   ├── bridge.dart         # OttoAdapter:overrides + routes(28 条)
│   │   ├── repository/ models/ services/
│   └── example/                # ExampleAdapter 骨架(新适配器模板)
├── pages/                      # 框架 UI(通用页:video/member/fav/history/search/
│                               #   dynamics/download/setting/rcmd/hot/about/webview...)
│   ├── providers.dart          # Host stub provider(适配器 override)
│   └── video/video_host.dart   # VideoHost 门面(export contract)
├── common/                     # 共享 widgets(0 适配器依赖)
├── player/                     # media_kit 播放器核心(0 适配器依赖)
├── router/                     # go_router:app_router/app_navigator/app_pages
├── utils/                      # storage(hive_ce)/theme/platform
└── main.dart                   # entry:AdapterRegistry → run App
```

### Key patterns

- **适配器选择(编译期)**:`--dart-define=ADAPTER=ottohub`(现默认)。
- **能力降级**:`VideoHost with DefaultPlayerCapabilities`——未覆写能力 = no-op + `supported=false`,页面隐藏入口。删除功能 = 删实现,**不删契约**。
- **Pages → Repository**:页面经 `appRead(xxxRepositoryProvider)` 取数据;provider 由适配器 override。
- **Host 注入**:`videoHostProvider/settingHostProvider/memberHostProvider/mainHostProvider/dynamicsHostProvider/mineActionsProvider/downloadActionsProvider` 定义于 `lib/pages/providers.dart`,由 `lib/adapters/riverpod_adapter_overrides.dart` 收集、bridge `registerDependencies()` 注入。
- **LoadingState<T>** 到处使用:sealed `Loading/Success/Error`。

## Adapter Status

| Adapter | Status | Notes |
|---|---|---|
| OttoHub | 数据层大半真实现;视频页(播放器/弹幕/简介/评论/相关)、用户页(投稿/动态)、动态页(博客)已接入 | 唯一运行态适配器 |
| Example | 骨架(全 UnimplementedError 指引) | 新适配器复制起点 |

## Testing

- **224 tests 全绿**:`test/repository/` envelope 测试(18 repo)、`test/adapters/ottohub/`(otto 真实现测试)、router/helpers 测试。
- mocks 由 build_runner 生成;删除 repo 时同步删对应 test 与 .mocks.dart。
- 无 widget/integration 测试。

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze | `flutter analyze` — 0 错误 0 警告 |
| Test | `flutter test` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Pub get | `flutter pub get`(本机 `PUB_CACHE=D:\FlutterCache`) |

## Build & release

- Flutter SDK patching:`lib/scripts/patch.ps1`(17 个 .patch,索引 Flutter 3.47.0;非 bilibili 专用,保留)。
- CI:`.github/workflows/build.yml`(android + ottohub_analyze + 各平台 reusable);产物命名已去 Bilibili。

## Dependencies

- git 分叉依赖(forks)大幅保留;删除的 11 个:Brotli/protobuf/http2/dio_http2_adapter/super_sliver_list/waterfall_flow/chat_bottom_container/flutter_sortable_wrap/live_photo_maker/dlna_dart/web_socket_channel。
- `ottohub_sdk_dart` 为 git 依赖(`github.com/SakuraCake/ottohub_sdk_dart`,包在子目录 `ottohub_sdk_dart/`,本地克隆于 `D:\...\GitHub\ottohub_sdk_dart`);0.0.3 已对齐 2026-09 服务端 REST 迁移,SDK 改动须在该仓库提交并推版。
- `flutter_html` 3.0.0 需 `html: 0.15.5+1` pin(**勿删**)。

## Gotchas

- **存储初始化**:`GStorage.init()` 失败(如 typeId 未知——跨适配器读取旧 Box)会走 `recoverInit`(备份损坏目录后重试);**Hive Box 内残留其他适配器 typeId 数据时启动会隔离重置**。
- `.gitignore`:`test_results/`、`*.mocks.dart`、`skf_release.json`。
- `distribute_options.yaml`:fastforge 输出 `dist/`。
- 历史遗留:部分 core 模型仍是 B 站 API 形状(member_types 等),深度净化见下方路线图。

## 路线图(未完成项)

1. `member_types.dart`(3395 行)重造为中立形状(充电/舰团/挂件/勋章字段仍在)。
2. 画质/音质码值(B 站 qn/302xx)中立化。
3. storage 残余 B 站语义键审计(msgBadge 域由 OttoHub msg 驱动)。
4. 登录 UI(密码登录 + 扫码)框架级实现。

## AGENTS.md hierarchy

```
AGENTS.md                    (root — this file)
├── lib/core/AGENTS.md
├── lib/adapters/ottohub/AGENTS.md
├── lib/adapters/example/AGENTS.md   (新适配器开发指南)
├── lib/common/AGENTS.md
├── lib/utils/AGENTS.md
├── lib/pages/AGENTS.md
└── lib/player/AGENTS.md
```
