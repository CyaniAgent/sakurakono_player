# Root Cleanup — Delete 10 Stale Refactoring Artifacts

## TL;DR (For humans)

删除根目录 10 个 SPES-012/013/014 重构残留的一次性脚本和 debug 产物。

## Scope

### Must have
- 删除 _analyze_errors.txt — 322 行过时错误快照
- 删除 temp_non_shim_files.txt — 1301 行 debug 路径列表
- 删除 8 个 .ps1 重构脚本（refactor_final.ps1, refactor_final2.ps1, refactor_fix.ps1, refactor_fix_tocore.ps1, refactor_fix_tocore2.ps1, refactor_phase2.ps1, refactor_loading_state.ps1, fix_tocore_parens.ps1）
- 删除后 `flutter analyze` 仍 0 errors
- 删除后 `flutter test` 仍 72/72 pass

### Must NOT have
- 不改任何 lib/ 下的代码文件
- 不改 .gitignore
- 不改 .omo/ 以外的配置文件

## Verification
- `flutter analyze` → 0 errors
- `flutter test` → 72/72 pass
- 确认 10 个文件已不存在于文件系统

## TODOs
1. [x] Delete 10 stale files from repo root
2. [x] Verify flutter analyze 0 errors + flutter test 72/72 pass
