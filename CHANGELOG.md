# Changelog

本变更日志按 git 提交历史生成，记录 SakuraKono Player Framework（SKF）自 fork 以来的变更。

- 项目从 [PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus) 2.1.0 fork，上游约 5100 个提交的历史不在此列出。
- `pubspec.yaml` 中 `version: 2.1.0+1` 继承自上游 PiliPlus 2.1.0 发布，SKF 尚无正式发布版本，故全部变更归入 Unreleased。
- 条目按主题聚类（SPES 阶段与重大重构），非逐提交罗列。

## [Unreleased]

### Added（新增）

- 项目初始化：fork 自 PiliPlus 2.1.0 并更名 SKF，替换 README、声明与上游的衍生关系。
- 多适配器框架：新增 `AppAdapter` / `AdapterRegistry` 抽象、`AccountMixin` 与新的 core 模型，支持编译期 `--dart-define=ADAPTER=...` 选择适配器。
- Repository 模式：定义 24 个核心 Repository 接口，`AccountProvider` 抽象与 B站 实现，数据层与页面解耦。
- OttoHub 适配器：实现 Repository（14 个真实实现 + 2 个部分实现，其余为防崩溃 stub）、播放器、账户提供者与 bridge。
- OttoHub SDK 本地化：将 `ottohub_sdk_dart` 供应商化到 `lib/ottohub_sdk_fix/` 并通过 `dependency_overrides` 指向本地路径。
- 统一播放入口：设置页「播放链接」+ `classifyPlayInput` 分类分发，支持 B站 URL / BV / av 与 OttoHub 纯数字视频 ID。
- 实现级测试：`FakeHttpAdapter` 测试框架、B站 / OttoHub Repository 实现级测试（覆盖 24 个核心接口）、`NumUtils.parseNum` 空安全测试。
- CI：新增 `ottohub_analyze` 任务，以 OttoHub 模式运行 `flutter analyze`。

### Changed（变更）

- 架构重构完成：编译错误从 692 个清零（SPES 全部计划落地），B站 业务代码隔离至 `adapters/bilibili/`，核心接口定义于 `lib/core/`。
- 类型安全（SPES-014）：Repository 参数从 `Object` 类型化为 `String` / `int`（91 处），Pref getter 显式类型化（34 个），B站 枚举 getter 迁移至 `BiliPref`。
- 消除 `as dynamic`：新增 `utils/model_converters.dart` 显式 Core→adapter 类型转换器，替换所有动态桥接站点（dynamics、article、later/history、follow、save/pgc/deeplink 等模块分批完成）。
- 媒体 ID 类型收敛：6 个 B站 专用媒体 ID 类型从 `lib/core/models/` 移入 adapter，core 仅保留 `CoreMediaId` 基类。
- 移除 `AppFeatures` 编译期特性开关，改为结构化功能移除（删除 GetPage 行 + 页面目录 + 仅用该功能的 Repository 注册），并清理失效的 dart-define 启动配置。
- 移除过时的 `ServiceRegistry` DI 包装；视频卡片「稍后再看」、关注等改经 Repository 注入。
- `lib/common/` 共享组件解耦（0 个 adapter import），简化本地文件插件，同步 JNI 绑定。
- Flutter 升级至 3.44.9，`dart fix --apply` 自动修复 64 个文件的警告。

### Fixed（修复）

- 修复 11 处 Core↔adapter 运行时类型不匹配崩溃站点（model_converters），并补充 Core 视频类型的 `toJson()`。
- 修复 `Pref.*.obs` 动态扩展分发在运行时的失败，改为显式类型断言。
- 修复 Accounts / Hive 初始化顺序：补充缺失的 `Accounts.init()` 调用、处理 GStorage 已打开的 Hive box、统一 `Box` 泛型类型。
- 页面级崩溃与边界修复：收藏夹空结果与分页边界、回复无效时长与截图失败、CDN 测速失败展示、空间 season/series 类型转换、动态徽章与弹幕 token 异步错误吞掉、IM 静音缓存状态保护、搜索类型转换崩溃、会员季/系列页崩溃。
- OttoHub 修复：文本动态改用 `submitBlog` 实现、下载 Repository 注入共享客户端、IM 会话操作加固（分页删除、偏移透传）。
- 补丁脚本：停用失效的 `geetest_ios.patch`，修复 `bottom_sheet_ios_app.patch`，补丁应用失败时立即报错（不再静默继续）。

### Removed（移除）

- 死表面清理：删除 `core/player/`、`core/plugin/`、适配器播放器工厂与上报器、`bilibili/account/` 与 `bilibili/router/` 重复文件、5 个无消费者的死 `AppAdapter` 成员。
- 删除 6 个 B站 专用媒体 ID 类型（零消费者）及无引用的 `SubtitleUtils` 类。
- 清理未使用 import、死代码与过期 adapter 类型 TODO 注释。

### Docs（文档）

- 建立分层 AGENTS.md 知识库（core / adapters / common / utils 各子目录一份）。
- README 更新：多适配器架构与 OttoHub 状态、统一播放入口说明、AI 辅助开发声明、JS/LUA 脚本引擎插件远期愿景。
- 记录 SPES-014 类型安全与 `as dynamic` 消除进展，以及结构化功能移除路径。
