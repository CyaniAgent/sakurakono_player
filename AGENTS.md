# AGENTS.md — SakuraKono Player / SKF

## Identity

- **SakuraKono Player Framework (SKF)**: 通用视频播放器 Flutter 框架模板。`pubspec.yaml name: skf`。Android package: `com.sakurakono.app`。
- **适配器**: OttoHub(`lib/adapters/ottohub/`,唯一真实适配器,数据层大部分真实现)+ ExampleAdapter(`lib/adapters/example/`,新适配器开发骨架)。
- 历史上的 Bilibili 适配器已于 2026-09-16 删除(快照 commit `bb7d917`);其"能力接口"以中立形状保留在 `lib/core/contract/player/`(片段跳过/系列/合集/笔记/听音频/互动视频/字幕/高能/下载)。
- 所有 `package:` imports 使用 `skf` 前缀;`lib/core`、`lib/pages`、`lib/common`、`lib/player` **零适配器 import**(grepped)。

## Current Phase

- **去 B 站化重构完成(2026-09-16)**:bilibili 适配器 982 文件删除;标准抽象接口层(`lib/core/contract/`)落地;OttoHub 为唯一真实适配器;存储键/B 站依赖已清理。
- **首页/动态/我的还原批次(2026-09-22)**:首页子 tab 重排为 热门(本周/本月/本季,timeLimit 7/30/90)/首页(顶部 `CarouselView.weighted` 轮播,数据 `AppRepository.slideshow()`,适配器探测首条封面尺寸上报 `CoreSlide.width/height`、高度按封面比例+官方上限推导,宽屏 M3 multi-browse `[1,2,3,2,1]`/窄屏 full-screen `[1]`,不覆写 padding/shape)/分区(`ZoneHost` 分类清单 + `categoryVideoList`,**服务端 num 上限 20**),默认「首页」;动态页三分类 最新(blogFeed)/关注(followDynamic,UP 面板全分类常驻,`OttoDynTabRegistry` 转发刷新/回顶)/推荐(randomBlogFeed),`CoreDynamicsTabType` 已中立化;用户详情页信息头由 `OttoMemberRepository.space()` 合成 images/统计/relation(following.getStatus),动态 tab 复用 `OttoDynamicsRepository.mapTimeline`;收藏详情页(`FavDetailPage`)复原 SliverAppBar.medium 信息卡,`userFavFolderDetail(collection:)` 按合集过滤(`getVideoCollectionDetail(uid, collection)`),`FavActions` 按成员门控隐藏无能力入口;我的页面未登录头像与 `NetworkImgLayer` avatar 占位改 MD 图标(Assets.avatarPlaceHolder 已删),登出为客户端清凭证(`clearCredentials`),mine provider 挂 Riverpod 登录态监听。
- **消息页重做 + 全页走查批次(2026-09-29,R21/R21b)**:`/whisper` = 私信会话列表 `MessagePage`(piliplus 时代 OttoHub 形态,经参考仓库 `D:\...\GitHub\piliotto` 移植):会话条目(头像/未读角标/最后消息/时间)+ AppBar「添加好友」弹窗(UID 查人 → 发私信建会话)+ 宽屏≥800 双栏(左 320 列表/右 `WhisperChatPanel`);聊天主体为框架级 `lib/pages/msg_feed_top/whisper_chat_panel.dart`,`/whisperDetail` 适配器页只包 Scaffold+AppBar。契约新增 `ImRepository.friendList` + `CoreImFriend`;分页 num=12(服务端上限)。**已删**:旧 回复/@/点赞 三 tab 消息中心(MsgCenterPage)与 reply_me/at_me/like_me/like_detail 四页及其路由、mine 页「评论记录」入口(`MineActions.openReply` 契约一并删)。未读徽章同源:home 与 mine 徽章都读 `MainController.msgUnReadCount`(遵循 `msgBadgeMode` 点/数字/隐藏),`MainController` 监听 `MessagePage.unreadRefresh`(会话页开关时广播)重查;未读查询失败保留旧值不闪没。mine 入口按压同 home 一样乐观清零。
- **轮播定案**:均匀大卡卡宽恒 = 高度×16/9(余量归右缘窥视条,不并入卡宽);Flutter 3.47 `CarouselView.weighted` 两个 SDK 断言的规避:weights 挂 `ValueKey(weights.join('_'))` 重建(避 didUpdateWidget position 未 attach 断言),视口 < slideWidth+peek 过渡态退化 full-screen(避非正权重断言),weights 键变化时帧后重置 `_leading=0` 防自动轮播跳页。
- **空态约定(全局)**:`Success(空列表)` 一律 `HttpError(isNotFound: true, errMsg: …)` 弱化空态,不得渲染为默认错误页(收藏/历史/黑名单/下载/关注/稍后再看/搜索等 12+ 处已清);Box 上下文内 `HttpError` 必须 `isSliver: false`。
- **搜索一致性**:结果页 `searchResultProvider` family 键 = 真实 keyword(勿用页面 tag/时间戳,否则 notifier 把 tag 当搜索词);`OttoSearchRepository` 映射 `pubdate` 为秒级 int(v.time 字符串需 `DateTime.tryParse ~/ 1000`)。
- **凭证自愈**:`ensureSessionValid` 失效判定覆盖 error_token/401/403/**404**(服务端对「可解密但会话已失效」token 回 nginx 404);2026-09-29 起 `/im` 域服务端回归(有效 token 全 404),消息数据不可用属服务端问题,App 侧优雅降级。
- **存储审计**:`GStorage.reply` 盒与 `saveReply` 设置(B 站评论图片缓存语义)已删,无消费者;Hive box 仅剩 userInfo/localCache/setting/historyWord/video/account/watchProgress。
- **路由**:纯 go_router(`MaterialApp.router`,`AppRouter.create`;门面 `AppNavigator`:`to/toNamed/back/parametersOf/arguments`)。路由表由激活适配器提供:`OttoBridge.routes`(29 条指向框架页)。
- **DI/状态**:Riverpod 全局 `appContainer`(`lib/core/container/app_container.dart`,非 widget 代码用 `appRead(provider)`)+ `ProviderContainer(overrides: adapterOverrides)`。
- **能力降级模式(核心设计)**:可选播放器能力(片段跳过/系列/合集/笔记/听音频/互动/字幕/高能/下载/播放源)定义为 `core/contract/player/` 下的独立接口;`VideoHost with DefaultPlayerCapabilities` 提供 no-op 默认(`supported=false`),适配器覆写 getter 返回自身即接入;页面对 null/不支持自动降级隐藏。**禁止 pages import 任何适配器**。
- **Controller 模式**:`CommonControllerRiverpod`/`CommonListControllerRiverpod`(ChangeNotifier);页面 `ListenableBuilder`。注册表模式:`Map<String, T> xxxRegistry` + `Provider.family`(member 页)。首页内嵌子页(热门子榜/分区)经 `HotCoordinator`/`ZoneCoordinator` 把外壳双击回顶/刷新代理到当前子页。
- **播放入口**:设置页「播放链接」→ `SettingHost.openVideoById`(适配器自实现跳转)。
- **已知边界(待接入)**:登录 UI 已有框架页(`/loginPage`,OttoHub 账密直传)+ 账号状态接线(启动恢复缓存/登录后同步 Riverpod)。视频页(播放器/弹幕/简介/评论/相关面板)、用户页(投稿/动态 tab)、动态页(博客流/博客详情 `/blogDetail`)均已接入。SDK 旧路由已按 2026-09 服务端 REST 迁移(comment/video/user/blog/danmaku;`/user/{uid}`、`/blog/latest`、`/blog/users/{uid}/blogs`、`/blog/{bid}/detail`、`/comment/videos/{vid}` 等)。OttoHub 分区名(0动画/1鬼畜/3音乐/4影视/5游戏/6综合/7娱乐)为内容抽样推断,**官方无名称表,修正点在 `otto_zone_host.dart`**;getCategory 无 offset(单批),randomBlog 无分页。

## SDK & env

- **Flutter 3.47.0 / Dart 3.13.0** — `.fvmrc` 与 pubspec 锁定。FVM 时用 `fvm flutter`。
- Dart MCP server 配置于 `opencode.jsonc`(`dart mcp-server`)。

## Linting & formatting

`analysis_options.yaml` extends `flutter_lints/flutter.yaml`,42 条显式规则(与删除前一致)。关键:
- `always_use_package_imports` — 所有 import 用 `package:skf/...`。
- `prefer_const_*`、`unnecessary_late`、`avoid_print`、`cascade_invocations`、`sized_box_for_whitespace` 等。
- `formatter: trailing_commas: preserve` — 不要增删尾逗号。
- `flutter analyze` 必须 **0 错误 0 警告 0 info**(2026-09-29 起全清,勿回退)。

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
│   │   ├── bridge.dart         # OttoAdapter:overrides + routes(29 条)
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
| OttoHub | 数据层大半真实现;视频页、用户页、首页(轮播/热门三榜/分区)、动态(最新/关注/推荐)、消息(私信会话列表/添加好友/宽屏双栏)、我的(本地登出)已接入 | 唯一运行态适配器;`/im` 域待服务端修复(2026-09-29 起有效 token 404) |
| Example | 骨架(全 UnimplementedError 指引) | 新适配器复制起点 |

## Testing

- **212 tests 全绿(2026-10-07)**:`test/adapters/ottohub/`(otto 实现级测试,FakeHttpAdapter)、`test/repository/`(注:mock 接口自身的弱覆盖结构,待改造)、router/helpers 测试;已接入 CI(build.yml analyze job 含 build_runner + flutter test)。
- mocks 由 build_runner 生成;删除 repo 时同步删对应 test 与 .mocks.dart。
- 无 widget/integration 测试。

## 验证门与提交规范

- **每批 commit 前全过适用门**(详表 `~/.agents/skills/audit-fix-workflow/references/gates.md`):
  - 所有批次:`flutter analyze` 0/0/0(不新增 ignore 豁免)+ 尾逗号 preserve 不增删 + diff 无调试残留。
  - 触碰被测逻辑/测试:`flutter test` 全绿;重写类用例数与断言密度不低于改前,删配套用例须在 commit 消息披露。
  - 触碰 pubspec/lock:`flutter pub get` 解析成功,lock 变更符合预期。
  - 触碰原生/依赖/构建脚本:至少 Android debug 构建通过(iOS 无法本地验证时以配置解析替代并注明)。
  - 触碰 plist/manifest/yaml/json:解析器实测(plistlib/yaml 解析),不目测。
  - 触碰凭据/CI secrets:grep 确认无新硬编码密钥。
- **commit 规范**:`<type>(<scope>): 中文主题`(fix/feat/docs/chore/refactor/perf/test),正文列 finding/任务 ID;单主题单批,可独立 revert;push 前由用户审阅。

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze | `flutter analyze` — 0 错误 0 警告 |
| Test | `flutter test` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Pub get | `flutter pub get`(本机 `PUB_CACHE=D:\FlutterCache`) |

## Build & release

- Flutter SDK patching:`lib/scripts/patch.ps1`(18 个 .patch,索引 Flutter 3.47.0;非 bilibili 专用,保留)。
- CI:`.github/workflows/build.yml`(android + ottohub_analyze + 各平台 reusable);产物命名已去 Bilibili。

## Dependencies

- git 分叉依赖(forks)大幅保留;删除的 15 个:Brotli/protobuf/http2/dio_http2_adapter/super_sliver_list/waterfall_flow/flutter_sortable_wrap/live_photo_maker/dlna_dart/web_socket_channel(2026-10 批次追加:app_links/archive/cookie_jar/encrypt/fixnum/fl_chart/json_annotation/material_color_utilities/mime/pretty_qr_code/synchronized/uuid/webdav_client 与插件 audio_service/audio_session/battery_plus/desktop_webview_window/image_cropper/package_info_plus)。
- `ottohub_sdk_dart` 为 git 依赖(`github.com/SakuraCake/ottohub_sdk_dart`,包在子目录 `ottohub_sdk_dart/`,本地克隆于 `D:\...\GitHub\ottohub_sdk_dart`);**0.0.14** 已对齐 2026-09 服务端 REST 迁移(0.0.12 解包 /profile data 载荷、0.0.13 following num 钳制、0.0.14 列表载荷兼容 data 层级 + blog favorite-list num 必传),SDK 改动须在该仓库提交并推版。
- `flutter_html` 3.0.0 需 `html: 0.15.5+1` pin(**勿删**)。
- **依赖浮动登记(单点风险,2026-10-08 用户裁决保持现状)**:`ottohub_sdk_dart` override 无 ref 跟踪 HEAD(兜底:pubspec.lock 钉 resolved-ref `ed14a5e`,重生成 lock 时会漂到最新);另有约 11 个 git 依赖钉分支而非 tag(main/dev/develop/mod/master/const,指向 bggRGjQaUbCoE / My-Responsitories fork)。更新 SDK 后须跑 `flutter pub get` 刷新 lock 并提交。

## Gotchas

- **存储初始化**:`GStorage.init()` 失败(如 typeId 未知——跨适配器读取旧 Box)会走 `recoverInit`(备份损坏目录后重试);**Hive Box 内残留其他适配器 typeId 数据时启动会隔离重置**。
- `.gitignore`:`test_results/`、`*.mocks.dart`、`skf_release.json`、`promo/`(宣传片工作目录,非项目文件)、`.mimosa/`/`.video_agent/`/`.zcode/`/`.cache/`(AI 工具产物)。
- `distribute_options.yaml`:fastforge 输出 `dist/`。
- 历史遗留:部分 core 模型仍是 B 站 API 形状(member_types 等),深度净化见下方路线图。

## 路线图(未完成项)

1. `member_types.dart`(3395 行)重造为中立形状(充电/舰团/挂件/勋章字段仍在)。
2. 画质/音质码值(B 站 qn/302xx)中立化。
3. storage 残余 B 站语义键审计(`GStorage.reply` 盒与 `saveReply` 已清,2026-09-29;余项继续)。
4. 扫码登录(OttoHub 无扫码 API;密码登录已实现:`/loginPage` 账密直传 + 凭证自愈)。
5. 服务端 `/im` 域修复(2026-09-29 起有效 token 404,App 侧已就绪)。

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
