# Fix Accounts.init() Runtime Crash

## Issue
App crashes on startup with `LateInitializationError: Field 'account' has not been initialized`
- `Accounts.init()` (opens Hive box) is never called
- `Accounts.refresh()` accesses `account.values` before init

## Fix (2 files)

### 1. `lib/main.dart`
- Add `import 'package:skf/adapters/bilibili/utils/accounts.dart';`
- Add `await Accounts.init();` after `await GStorage.init();` (line 93)

### 2. `lib/adapters/bilibili/bridge.dart`
- Remove import for `package:skf/adapters/bilibili/http/init.dart` if it was only needed for setCookie — actually keep it, still needed

## Verification
```powershell
flutter analyze 2>&1 | Select-String "^  error" | Measure-Object -Line
flutter test
flutter run -d windows  # verify app starts without crash
```

## Commit
```
fix: add missing Accounts.init() call before Accounts.refresh()
```
