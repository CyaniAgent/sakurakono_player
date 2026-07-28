# Fix ReplyController `int.obs` Runtime Crash

## Issue
`NoSuchMethodError: Class 'int' has no instance getter 'obs'` at `reply_controller.dart:48`

## Root Cause
`Pref.replySortType` returns `dynamic` (int 0). Extension methods (`.obs`) are NOT resolved on `dynamic` receivers in Dart — they work at compile time but fail at runtime.

## Fix (1 file)
**`lib/adapters/bilibili/pages/common/reply_controller.dart`** line 47-48:

```dart
// BEFORE:
final cacheSortType = Pref.replySortType;
sortType = cacheSortType.obs;

// AFTER:
final cacheSortType = Pref.replySortType as int;
sortType = ReplySortType.values[cacheSortType].obs;
```

## Verification
```powershell
flutter analyze 2>&1 | Select-String "^  error" | Measure-Object -Line
flutter test
```

## TODOs
1. [ ] Fix reply_controller.dart line 47-48 dynamic.obs crash
