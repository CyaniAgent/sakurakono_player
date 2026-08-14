# 贡献指南（CONTRIBUTING）

## 项目简介

SakuraKono Player Framework（SKF，`package:skf`）是基于 Flutter 的通用视频播放器框架，为各类视频应用提供开箱即用的模板。项目背景、功能现状与 Roadmap 见 [README.md](README.md)。

## 开发环境

- **Flutter 3.44.9 / Dart `>=3.12.0`**：版本由 `.fvmrc` 固定，建议使用 `fvm flutter`（FVM 已配置）。更换 Flutter 版本会破坏 SDK 补丁（见下）。
- 安装依赖：`flutter pub get`（不是 `dart pub get`；依赖含大量 git fork 与 `lib/ottohub_sdk_fix` 本地路径覆盖）。

## 常用命令

| 命令 | 说明 |
|------|------|
| `flutter analyze` | 裸跑静态分析（不支持 `--dart-define`，CI 同款），必须 **0 errors 0 warnings** |
| `flutter test` | 跑全部 **232** 个测试 |
| `dart run build_runner build --delete-conflicting-outputs` | 生成 `*.mocks.dart`（已被 gitignore，提交前需重新生成） |
| `flutter run --dart-define=ADAPTER=bilibili` | 启动 B站 适配器（默认模式） |
| `flutter run --dart-define=ADAPTER=ottohub` | 启动 OttoHub 适配器 |
| `flutter build apk --release` | Android 构建；其余平台命令见 [AGENTS.md](AGENTS.md) 的「Build & release」节 |

**运行/构建前**须先执行 `lib/scripts/patch.ps1 <platform>`：该脚本向 Flutter SDK 应用本地补丁，版本锁定 3.44.9，换版本会破坏补丁。

## 代码规范

- `analysis_options.yaml` 配置了 **42 条** lint 规则（在 `flutter_lints` 基础上追加）。其中 `always_use_package_imports` / `avoid_relative_lib_imports` 要求所有导入一律使用 `package:skf/...`，禁止相对导入。
- **架构边界**：`lib/core/` 与 `lib/common/` 禁止导入 `lib/adapters/`（契约层不依赖任何适配器，grep 已校验）。
- **生成文件**：不编辑 `*.pb.dart`、`*.g.dart` 等生成文件。
- **OttoHub stub 仓库反造假契约**：SDK 未实现的方法留桩并加注释说明，不得伪造实现。
- **数据访问**：页面一律通过 `Get.find<Repository>()` 调用核心接口，不直接发 HTTP。

## 提交规范

- 使用 **conventional commits**：`feat` / `fix` / `refactor` / `chore` / `test` / `docs`，可加 scope，如 `feat(bilibili): ...`。
- **单任务单 commit**，一个逻辑变更一个提交。
- 提交前自检：`flutter analyze` 达到 0 errors 0 warnings，`flutter test` 全绿。

## 分支与 PR

- 仓库现状允许 **main 直推或开 PR**，两种方式均可。
- 开 PR 会触发 CI：**android + win_x64 + ottohub_analyze**（ios/mac/linux 构建仅手动触发）。

## 测试要求

- 新功能至少补**实现级测试**：参考 `test/adapters/` 的模式，网络请求用 `test/helpers/fake_http_adapter.dart` 替换。
- **测试不得触网**，不依赖真实网络环境。
- mock 通过 `@GenerateMocks` 标注核心接口生成，改动后运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 `*.mocks.dart`。

## 架构速览

`lib/core/` 是契约层（`AppAdapter`、24 个 Repository 接口、`LoadingState<T>`），`lib/adapters/<name>/` 是各平台适配器（Bilibili 完整、OttoHub 进行中），`lib/common/` 是共享组件；统一播放入口在设置页「播放链接」，自动识别 B站 链接/BV/av 与 OttoHub 纯数字 ID。详细说明见 [docs/architecture.md](docs/architecture.md)（本轮新增）。

## AI 辅助开发

本项目使用 AI 工具辅助开发（详见 README 的「AI 辅助开发声明」）。**AI 生成的代码需经人工 review**，确认符合上述规范与测试要求后再合入。
