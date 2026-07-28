# Fix All `Pref.*.obs` Runtime Crashes

## Problem
`Pref.*` getters return `dynamic` (from Hive). Extension methods (`.obs`) are NOT dispatched on `dynamic` receivers in Dart — they crash at runtime with `NoSuchMethodError`.

## Scope
17 occurrences across 10 files.

## Fix Pattern
For each `Pref.*.obs` call, add `as Type` cast before `.obs`:

```dart
// BEFORE (crashes):
Pref.playSpeedDefault.obs

// AFTER (works):
(Pref.playSpeedDefault as double).obs
```

For enum types, use `.values[int]` constructor:
```dart
// BEFORE:
Pref.replySortType.obs

// AFTER:
ReplySortType.values[Pref.replySortType as int].obs
```

## Files & Fixes

| # | File | Line | Variable Type | Fix |
|---|------|------|---------------|-----|
| 1 | `pl_player/controller.dart` | 104 | `RxDouble` | `(Pref.playSpeedDefault as double).obs` |
| 2 | `pl_player/controller.dart` | 105 | `RxDouble` | `(Pref.longPressSpeedDefault as double).obs` |
| 3 | `pl_player/controller.dart` | 130 | `RxBool` | `(Pref.continuePlayInBackground as bool).obs` |
| 4 | `pl_player/controller.dart` | 192 | `RxBool` | `(Pref.enableShowDanmaku as bool).obs` |
| 5 | `pl_player/controller.dart` | 193 | `RxBool` | `(Pref.enableShowLiveDanmaku as bool).obs` |
| 6 | `pl_player/controller.dart` | 311 | `RxDouble` | `(Pref.danmakuOpacity as double).obs` |
| 7 | `pay_coins/view.dart` | 67 | `RxBool` | `(Pref.coinWithLike as bool).obs` |
| 8 | `video/controller.dart` | 158 | `RxBool` | `(Pref.autoPlayEnable as bool).obs` |
| 9 | `audio/controller.dart` | 90 | `Rx<PlayRepeat>` | `PlayRepeat.values[Pref.audioPlayMode as int].obs` |
| 10 | `color_select.dart` | 220 | `RxBool` | `(Pref.dynamicColor as bool).obs` |
| 11 | `color_select.dart` | 221 | `RxInt` | `(Pref.customColor as int).obs` |
| 12 | `color_select.dart` | 222 | `Rx<ThemeType>` | `ThemeType.values[Pref.themeType as int].obs` |
| 13 | `search/controller.dart` | 59 | `RxBool` | `(Pref.recordSearchHistory as bool).obs` |
| 14 | `mine/controller.dart` | 35 | `Rx<ThemeType>` | `ThemeType.values[Pref.themeType as int].obs` |
| 15 | `later/base_controller.dart` | 14 | `RxBool` | `(Pref.enablePlayAll as bool).obs` |
| 16 | `follow/child_controller.dart` | 28 | `Rx<FollowOrderType>` | `FollowOrderType.values[Pref.followOrderType as int].obs` |
| 17 | `fav_detail/controller.dart` | 89 | `RxBool` | `(Pref.enablePlayAll as bool).obs` |
| 18 | `reply_controller.dart` | 48 | `Rx<ReplySortType>` | `ReplySortType.values[Pref.replySortType as int].obs` |

## Verification
```powershell
flutter analyze 2>&1 | Select-String "^  error" | Measure-Object -Line
flutter test
```

## TODOs
1. [ ] Fix all 17+1 Pref.*.obs runtime crashes across 10 files
