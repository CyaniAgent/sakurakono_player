# SPES-014: Fix Remaining View Layer Type Mismatches

## 决策完整计划 — 可独立执行

本计划面向一个**无上下文的新 worker 会话**执行。每一步都包含：确切文件、确切修改、验证命令。执行者零判断空间。

---

## 总览

### 当前状态
| 指标 | 值 |
|------|-----|
| 剩余错误 | **261** |
| 影响文件 | ~55 files |
| 根因 | 全部是 `CoreXxx`↔`Xxx` 类型不匹配 |
| Core 模型完整性 | ✅ 已全部定义 |
| 测试 | ✅ 72/72 通过 |
| 核心层 (lib/core/) | ✅ 无错误 |

### 修复策略 — 自顶向下三步

```
Step 1: Controller 字段类型修正（~150 errors）→ 
Step 2: Getter/属性修正（~50 errors）→ 
Step 3: 泛型/杂项（~61 errors）→ 
Verify: flutter analyze 0 errors + flutter test
```

**每步完成后运行 `flutter analyze` 检查进度。不跳过验证。**

---

## Step 1: 修复 Controller 字段类型（主力步骤，~150 errors）

### 问题模式
```dart
// 错误：Rx<LoadingState<Xxx>> 接收到 LoadingState<CoreXxx>
Rx<LoadingState<ArticleListItemModel>> list;  // ← Xxx 需要改成 CoreXxx

// 修复：
Rx<LoadingState<CoreArticleListItemModel>> list;  // ← 加 Core 前缀
// 同时把 import 从 adapters/... 改成 core/models/...
```

### 1A: `article` 系列（~20 errors in 4 files）

**文件 `lib/adapters/bilibili/pages/article/controller.dart`**
- 字段 `articleData`: 类型 `dynamic`→`CoreArticleViewData`（同时修复 import）
- 字段 `list`: 类型 `Rx<LoadingState<List<ArticleListItemModel>?>>`→`Rx<LoadingState<List<CoreArticleListItemModel>?>>`
- 方法返回值: `FollowUpModel?`→`CoreFollowUpModel?`

**文件 `lib/adapters/bilibili/pages/article_list/controller.dart`**
- 字段 `articleList`: `LoadingState<ArticleListInfo>`→`LoadingState<CoreArticleListInfo>`
- 字段 `items`: `RxList<ArticleListItemModel>`→`RxList<CoreArticleListItemModel>`

### 1B: `dynamics_*` 系列（~15 errors in 6 files）

**文件 `lib/adapters/bilibili/pages/dynamics/controller.dart`** — 已修复（0 errors）
**文件 `lib/adapters/bilibili/pages/dynamics/view.dart`**
- `controller.dynList` 的类型链: `LoadingState<FollowUpModel>`→`LoadingState<CoreFollowUpModel>`

**文件 `lib/adapters/bilibili/pages/dynamics_tab/controller.dart`**
- `DynamicsDataModel`→`CoreDynamicsDataModel`, `DynamicItemModel`→`CoreDynamicItemModel`

**文件 `lib/adapters/bilibili/pages/dynamics_topic/controller.dart`**
- `TopicCardItem`→`CoreTopicCardItem`, `TopicSortByConf`→`CoreTopicSortByConf`

### 1C: `fav_*` 系列（~15 errors in 5 files）

**文件 `lib/adapters/bilibili/pages/fav_detail/controller.dart`**
- `FavDetailData`→`CoreFavDetailData`, `FavDetailItemModel`→`CoreFavDetailItemModel`
- `FavFolderInfo`→`CoreFavFolderInfo`, `FavOrderType`→`CoreFavOrderType`

**文件 `lib/adapters/bilibili/pages/fav_search/controller.dart`**
- `FavDetailData`→`CoreFavDetailData`, `FavDetailItemModel`→`CoreFavDetailItemModel`

**文件 `lib/adapters/bilibili/pages/fav/(article|cheese|video|pgc|note|topic)/controller.dart`**
- 每个文件中的 `LoadingState<List<Xxx>>`→`LoadingState<List<CoreXxx>>`

### 1D: `live_*` 系列（~15 errors in 5 files）

**文件 `lib/adapters/bilibili/pages/live_room/controller.dart`**
- `RoomInfoH5Data`→`CoreRoomInfoH5Data`, `DanmakuMsg`→`CoreDanmakuMsg`
- `SuperChatItem`→`CoreSuperChatItem`, `LiveEmoteDatum`→`CoreLiveEmoteDatum`

**文件 `lib/adapters/bilibili/pages/live_area_detail/controller.dart`**
- `RoomPlayInfoData`→`CoreRoomPlayInfoData` (if present)

### 1E: `member_*` 系列（~20 errors in 8 files）

**文件 `lib/adapters/bilibili/pages/member_video/controller.dart`**
- 行 36: `EpisodicButton? episodicButton;` → `CoreEpisodicButton? episodicButton;`
- 行 81: `episodicButton = data.EpisodicButton;` → `episodicButton = data.coreEpisodicButton;`

**文件 `lib/adapters/bilibili/pages/member_opus/controller.dart`**
- `SpaceOpusData`→`CoreSpaceOpusData`（如果存在，否则 `dynamic`）

**其他 member_* 文件**: 所有 `LoadingState<List<Xxx>>`→`LoadingState<List<CoreXxx>>`

### 1F: `search_*` + `msg_*`（~20 errors in 6 files）

**文件 `lib/adapters/bilibili/pages/search_panel/controller.dart`**
- `SearchAllData`→`CoreSearchAllData`, `SearchSuggestModel`→`CoreSearchSuggestModel`

**文件 `lib/adapters/bilibili/pages/whisper*/controller.dart`**
- `ImUserInfosData`→`CoreImUserInfosData`, `SessionSsData`→`CoreSessionSsData`
- `UidSetting`→`CoreUidSetting`

### 1G: 其他 controller（~30 errors in 15 files）

**文件 `lib/adapters/bilibili/pages/audio/controller.dart`** — 最重文件（~22 errors）
- `AudioPlaylistResp`→`CoreAudioPlaylistResp`（字段 `paginationReply`、`list`）
- `AudioListOrder`→`CoreAudioListOrder`, `AudioPageOption`→`CoreAudioPageOption`
- `PlayURLResp`→`CoreAudioPlayUrlResp`, `ThumbUpResp`→`CoreAudioThumbUpResp`
- 所有 `LoadingState<Xxx>`→`LoadingState<CoreXxx>`
- 需要 import: `core/models/audio_types.dart`

**文件 `lib/adapters/bilibili/pages/bubble/controller.dart`**
- `BubbleData`→`CoreBubbleData`, `DynList`→`CoreDynList`

**文件 `lib/adapters/bilibili/pages/history/controller.dart`** + `later/controller.dart`
- `HistoryData`→`CoreHistoryData`, `LaterData`→`CoreLaterData`

**文件 `lib/adapters/bilibili/pages/subscription/controller.dart`** + `subscription_detail/controller.dart`
- `SubData`→`CoreSubData`, `SubDetailData`→`CoreSubDetailData`

**文件 `lib/adapters/bilibili/pages/login_devices/controller.dart`**
- `LoginDevicesData`→`CoreLoginDevicesData`（注意：有双 Core 前缀的 typo `CoreCoreLoginDevicesData`）

### 通用规则 for Step 1
```
对每个 `argument_type_not_assignable` 错误：
  1. 看目标参数类型是 Xxx → 改为 CoreXxx
  2. 看 import 来源是 adapters/ → 改为 core/models/xxx_types.dart
  3. 不要改源表达式（source expression），只改目标类型声明

对每个 `invalid_assignment` 错误：
  1. 看变量声明是 Xxx → 改为 CoreXxx
  2. 同样更新 import
```

---

## Step 2: 修复 Getter/属性（~50 errors）

### 问题模式
```dart
// 错误：data.CoreElec（把类型名当成 getter 用了）
data.CoreElec  // ← CoreElec 是类型不是 getter

// 修复：用 Core 模型的实际字段名
data.elec  // ← 或者 data['elec']，取决于 CoreSpaceData 的定义
```

### 2A: `member/controller.dart`（~5 errors）
- `CoreElec`→`elec`（CoreSpaceData 的字段）
- `CoreGuard`→相关 guard 字段
- `CoreLive`→相关 live 字段
- `CoreUgcSeason`→相关 ugcSeason 字段
- `CoreEpisodicButton`→`episodicButton`（在 CoreSpaceArchiveData 上）

### 2B: 其他 undefined_getter
浏览 `member_video/controller.dart`、`member/view.dart`、`member_home/` 等文件：
- 查看 Core 类型有哪些字段（读 `core/models/member_types.dart`）
- 把 `data.SomeTypeName` 改为 `data.actualFieldName`

### 通用规则 for Step 2
```
对每个 `undefined_getter` 错误：
  1. 打开对应的 Core 类型定义文件（`lib/core/models/xxx_types.dart`）
  2. 查看该类有哪些字段/ getter
  3. 把 `data.TypeName` 改为 `data.actualField`
  
对每个 `unchecked_use_of_nullable_value` 错误：
  1. 在访问链上添加 `?.` 空安全操作符
  2. 或者在合适的位置添加 null 检查
```

---

## Step 3: 修复泛型/杂项（~61 errors）

### 3A: `type_argument_not_matching_bounds`（~7 errors）
`CoreXxx` 类型不满足 `MultiSelectData` 约束。修复：
- 给 Core 类型添加 `with MultiSelectData`，或者
- 在核心定义文件中添加 `MultiSelectData` mixin 的引入

### 3B: `invalid_override`（~7 errors）
Controller 子类的泛型参数不匹配父类。修复：
- 把子类 override 方法中的泛型参数从 `Xxx` 改为 `CoreXxx`

### 3C: `mixin_application_not_implemented_interface`（~3 errors）
Mixin 类型参数不匹配。修复：
- 调整 `with` 子句中的泛型参数

### 3D: 特殊修复
- **`CoreCoreLoginDevicesData`**（1 error）：双 Core 前缀 typo → `CoreLoginDevicesData`（在 `lib/adapters/bilibili/pages/login_devices/controller.dart`）
- **`Int64?`→`int?`**（~5 errors）：gRPC 的 `Int64?` 不能赋值给 `int?` → 添加 `.toInt()` 或 `?.toInt() ?? 0`
- **`Object?`→`Map<String, dynamic>?`**（~3 errors）：添加 `as Map<String, dynamic>?` 强制转换
- **`non_exhaustive_switch`**（~2 errors）：添加 `Object()` 兜底分支

---

## 验证命令

### 每步验证（快速）
```powershell
flutter analyze lib/adapters/bilibili/pages/xxx/controller.dart  # 单文件检查
```

### 最终验证
```powershell
flutter analyze 2>&1 | Select-String "^  error" | Measure-Object -Line
# 期望输出: 0
```

```powershell
flutter test
# 期望输出: All 72 tests passed
```

---

## Todo 清单

### Step 1: Controller 字段类型修正
- [x] 1A. `article_*` controller（4 files）— ✅ 已修复
- [x] 1B. `dynamics_*` controller（6 files）— ✅ 已修复
- [x] 1C. `fav_*` controller（5 files）— ✅ 已修复
- [x] 1D. `live_*` controller（5 files）— ✅ 已修复
- [x] 1E. `member_*` controller（8 files）— ✅ 已修复
- [x] 1F. `search_*` + `msg_*` controller（6 files）— ✅ 已修复
- [x] 1G. 其他 controller（~15 files, 含 `audio/controller.dart`）— ✅ 已修复

### Step 2: Getter/属性修复
- [x] 2A. `member/controller.dart` undefined_getter — ✅ 已修复
- [x] 2B. 其他 undefined_getter + null safety — ✅ 已修复

### Step 3: 泛型/杂项
- [x] 3A. MultiSelectData 约束修复 — ✅ 已修复
- [x] 3B. invalid_override 修复 — ✅ 已修复
- [x] 3C. mixin 修复 — ✅ 已修复
- [x] 3D. 特殊修复（CoreCore typo, Int64→int, 等） — ✅ 已修复

### Step 4: 验证
- [x] 4A. `flutter analyze` — 0 errors — ✅
- [x] 4B. `flutter test` — 72/72 pass — ✅

## 最后检查
- [x] F1. 没有修改 `lib/core/models/` — ✅
- [x] F2. 没有修改 BiliBridge/DI — ✅
- [x] F3. `grep "adapters/bilibili" lib/core/` — 0 matches — ✅
