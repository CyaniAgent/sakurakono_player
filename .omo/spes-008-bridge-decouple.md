# SPES-008: Bridge 修复 + B站 全面解耦（合理性修正版）

## 🔍 合理性验证结论

通过全量 grep 验证引用关系后发现：

1. **BiliConstants 已存在** — `adapters/bilibili/common/constants.dart` 已含全部 B站 常量，与 `lib/common/constants.dart` 重复。无需新建文件。
2. **app_scheme.dart (919行)** — 25 个引用者中 24 个在 adapter 内 → **应移动，不拆分**
3. **page_utils.dart (819行)** — 93 个引用者中 88 个在 adapter 内 → **应移动，不拆分**
4. **video_cards / video_popup_menu** — 100% 被 adapter 页面引用 → **应移动，不拆分**
5. **唯一需拆分的文件**: `storage_pref.dart`（混合通用+B站）

修正后工作量: 修改 16 + 移动 16 + 新建 3 = 35 文件（原计划 47 文件，减少 25%）。

---

## 阶段 A — Bridge 层修复（5 文件，0 新建）

### A1: `main()` → `BiliBridge.register()`
- bridge 补充 `AccountService`、`DownloadService`、`setupServiceLocator()` 注册
- main 删除对应三行及 import

### A2: HTTP 初始化移入 bridge
- `Request()` / `Request.setCookie()` / `RequestUtils.syncHistoryStatus()` → bridge
- main 删除对应三行

### A3: 修复 `_PlPlayerAdapter.open()`
- 实现真实播放 → `PlPlayerController.getInstance().open(source, ...)`
- 生命周期（play/pause/seek/complete）触发 reporter 回调

### A4: 实现 `BiliAccountProvider`
- `onAuthStateChanged()` 监听 `Accounts.main`

### A5: `ServiceRegistry` 标记 `@Deprecated`

```bash
flutter analyze  # 0 errors
```

---

## 阶段 B — constants 去重（2 文件，0 新建）

**关键发现**: `lib/adapters/bilibili/common/constants.dart` 已有 `class BiliConstants`，与 `lib/common/constants.dart` 内容完全重复。

| 操作 | 详情 |
|------|------|
| 删除 `lib/common/constants.dart` 中 B站 常量 | appKey~dynFeatures（行 8-46） |
| 保留通用常量 | `appName`（引用 AppMeta）、`urlRegex` |
| 统一引用 | 15 个 adapter 内文件 + 4 个外部文件 → `BiliConstants.xxx` |

**引用者清单** (19 文件):
- 15 在 adapter 内 → 直接改 import
- `main.dart` → 只用 `appName`（保留）
- `update.dart` → C 阶段会移动
- `image_utils.dart` → C 阶段会拆分
- `audio_handler.dart` → 已在 adapter

---

## 阶段 C — utils/ 解耦（3 拆分 + 8 移动）

### 拆分文件（3 个 — 混合通用+B站）

| 文件 | B站 部分 | 目标 |
|------|----------|------|
| `storage_pref.dart` (1035行) | buvid, B站 quality types, antifraud, blockSettings | `adapters/bilibili/utils/bili_storage_pref.dart` |
| `image_utils.dart` | `GlobalData().imgQuality` | adapter 扩展 |
| `json_file_handler.dart` | `LoggerUtils` import | Logger 初始化移到 bridge |

### 移动文件（8 个 — 100% B站）

| 源文件 | 引用者 | 目标 |
|------|--------|------|
| `app_scheme.dart` (919行) | 24/25 adapter | `adapters/bilibili/utils/app_scheme.dart` |
| `page_utils.dart` (819行) | 88/93 adapter | `adapters/bilibili/utils/page_utils.dart` |
| `url_utils.dart` | B站 IdUtils | `adapters/bilibili/utils/url_utils.dart` |
| `update.dart` | B站 API | `adapters/bilibili/utils/update.dart` |
| `reply_utils.dart` | B站 API | `adapters/bilibili/utils/reply_utils.dart` |
| `waterfall.dart` | GlobalData | `adapters/bilibili/utils/waterfall.dart` |
| `extension/theme_ext.dart` | BiliColors | `adapters/bilibili/utils/extension/theme_ext.dart` |
| `extension/three_dot_ext.dart` | B站 grpc | `adapters/bilibili/utils/extension/three_dot_ext.dart` |

### 其他操作

| 文件 | 操作 |
|------|------|
| `storage.dart` | B站 Hive adapter 注册 → `BiliBridge._initHive()` |
| `storage_key.dart` | `biliSendCommAntifraud`/`mixinKey`/`buvid` → adapter |

---

## 阶段 D — widgets/ 移动（6 移动）

| 源文件 | 引用者 | 目标 |
|------|--------|------|
| `video_popup_menu.dart` (332行) | 3 全 adapter | `adapters/bilibili/common/widgets/video_popup_menu.dart` |
| `video_card/video_card_v.dart` (283行) | 10 全 adapter | `adapters/bilibili/common/widgets/video_card/video_card_v.dart` |
| `video_card/video_card_h.dart` | 10 全 adapter | `adapters/bilibili/common/widgets/video_card/video_card_h.dart` |
| `image/image_save.dart` | adapter 内 | `adapters/bilibili/common/widgets/image/image_save.dart` |
| `dialog/report_member.dart` | adapter 内 | `adapters/bilibili/common/widgets/dialog/report_member.dart` |
| `dialog/report.dart` | adapter 内 | `adapters/bilibili/common/widgets/dialog/report.dart` |

---

## 阶段 E — pages/common/ 移动（2 移动）

| 源文件 | 目标 |
|------|------|
| `fav_helper.dart` (18行) | `adapters/bilibili/pages/common/fav_helper.dart` |
| `home_tab_helper.dart` (32行) | `adapters/bilibili/pages/common/home_tab_helper.dart` |

移动后 `lib/pages/` 目录清空。

---

## 阶段 F — core/ 清理（5 修改）

### 文档注释去 B站 化
- `video_quality.dart` / `audio_quality.dart` — 移除 doc 中 "B站"
- `playback_reporter.dart` — 移除 "e.g. B站 heartbeat"
- `loading_state.dart` — 移除 "B站 LoadingState"

### `media_id.dart` — B站 ID 类型处理
- Bvid/Aid/Sid/Epid/Cid/RoomId → `@Deprecated`，建议移到 adapter
- `LocalPath` 保留

---

## 阶段 G — router/ 解耦（1 修改）

1. `BiliBridge.registerRoutes()` → `List<GetPage>` 包含 69 个 B站 页面路由
2. `app_pages.dart` 只保留通用路由 ('/' → MainApp)
3. `Routes.getPages` 合并: 通用 + `BiliBridge.registerRoutes()`

---

## 阶段 H — 最终验证

```bash
flutter analyze  # 0 errors
```

## 验收标准

- [ ] `main()` 无 `adapters/bilibili/` import
- [ ] `lib/utils/` 无 `adapters/bilibili/` import
- [ ] `lib/common/` 无 `adapters/bilibili/` import
- [ ] `lib/pages/` 已清空
- [ ] `lib/router/app_pages.dart` 无 B站 页面 import
- [ ] `BiliBridge.register()` 是 B站 适配器唯一入口

## 产出清单

| 阶段 | 修改 | 移动 | 新建 |
|------|------|------|------|
| A: Bridge | 5 | 0 | 0 |
| B: Constants | 2 | 0 | 0 |
| C: Utils | 3(拆) | 8 | 3 |
| D: Widgets | 0 | 6 | 0 |
| E: Pages | 0 | 2 | 0 |
| F: Core | 5 | 0 | 0 |
| G: Router | 1 | 0 | 0 |
| **合计** | **16** | **16** | **3** |

vs 原计划: 修改 35 + 新建 12 = 47 → **减少 25%，且移动比拆分接口简单得多**
