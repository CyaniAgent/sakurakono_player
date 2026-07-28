# SPES-009: 重命名 PiliPlus → skf（合理性修正版）

## 🔍 合理性验证补充

通过全量审计 31 个非 .dart 引用文件后发现原计划遗漏：

| 遗漏项 | 详情 |
|--------|------|
| `linux/CMakeLists.txt` | 含 `piliplus` 引用 |
| `windows/CMakeLists.txt` | 含 `PiliPlus` 引用 |
| 3 个 AndroidManifest.xml | debug/profile 变体也有 `package` 属性 |
| `shortcuts.xml` | Android 快捷方式使用 `bilibili://` scheme |
| GitHub org 名不一致 | CI 用 `bggRGjQaUbCoE/PiliPlus`，README 用 `CyaniAgent/sakurakono_player` |

---

## 替换映射表

| 匹配模式 | 替换为 | 影响 |
|----------|--------|------|
| `package:PiliPlus/` | `package:skf/` | 962 .dart |
| `PiliPlus` (显示名) | `SakuraKono` | Android/iOS/Windows/文档 |
| `piliplus` (小写路径) | `sakurakono` | Linux/Win CMake, 产物名 |
| `com.example.piliplus` | `com.sakurakono.app` | Android manifest/gradle/Java/Kotlin |
| `pili_release.json` | `skf_release.json` | CI workflow |

---

## 步骤

### 1 — 脚本批量替换

PowerShell 脚本遍历所有文件类型 (`.dart` `.xml` `.gradle.kts` `.kt` `.java` `.plist` `.yaml` `.yml` `.ps1` `.patch` `.md` `.txt`)，执行上表替换。

**关键文件**:

| 文件 | 改动 |
|------|------|
| `pubspec.yaml` | `name: skf` |
| `lib/core/app_meta.dart` | `appName = 'SakuraKono'`, `packageName = 'skf'` |
| `AGENTS.md` | 全面更新项目身份、import 规则 |

### 2 — Android 目录移动

```
kotlin/com/example/piliplus/ → kotlin/com/sakurakono/app/
java/com/example/piliplus/   → java/com/sakurakono/app/
```

**升级中断警告**: 更改 `applicationId` 后现有用户无法直接升级。已确认用户接受此风险。

### 3 — 平台清单文件

| 平台 | 文件 | 改动 |
|------|------|------|
| Android | `build.gradle.kts` | `namespace`、`applicationId` |
| Android | `main/src/AndroidManifest.xml` | `package`、intent labels |
| Android | `debug/src/AndroidManifest.xml` | `package` |
| Android | `profile/src/AndroidManifest.xml` | `package` |
| Android | `res/values/string.xml` | `app_name` |
| Android | `debug/res/values/string.xml` | `app_name` |
| Android | `res/xml-v25/shortcuts.xml` | `bilibili://` → 需确认是否保留 |
| iOS | `Runner/Info.plist` | `CFBundleDisplayName`、`CFBundleName`、URL schemes |
| Windows | `packaging/exe/make_config.yaml` | `display_name`、`publisher_url` |
| Windows | `runner/main.cpp` | 窗口标题 `L"sakurakono"` |
| Windows | `CMakeLists.txt` | `PiliPlus` 引用 |
| Linux | `CMakeLists.txt` | `piliplus` 引用 |

### 4 — CI/CD 工作流更新

6 个 `.github/workflows/*.yml` 文件:
- 仓库条件: `github.repository == 'CyaniAgent/sakurakono_player'`（与 README 一致）
- 产物名: `PiliPlus_*` → `SakuraKono_*`
- 二进制名: `piliplus` → `sakurakono`
- `dart-define-from-file` 统一为 `skf_release.json`

### 5 — 文档

- `AGENTS.md` — 项目身份、包名、import 规则
- `README.md` — 更新描述（当前已用 SKF 名称，需检查一致性）
- `docs/spes/README.md` — 更新包名引用

### 6 — 验证

```bash
# 无残留 PiliPlus 引用
rg "package:PiliPlus" --type dart           # → 空
rg "com\.example\.piliplus"                 # → 空
rg "PiliPlus" --glob '!docs/spes/*' --glob '!.omo/*'  # → 仅文档遗留

# 编译验证
flutter analyze                    # → 0 errors
flutter build apk --release        # → 编译通过
```

---

## 验收标准

- [ ] `rg "package:PiliPlus" --type dart` 返回空
- [ ] `rg "com.example.piliplus"` 返回空
- [ ] Android `applicationId = com.sakurakono.app`，编译通过
- [ ] iOS `CFBundleDisplayName = SakuraKono`
- [ ] Windows 窗口标题 `sakurakono`
- [ ] Linux/Win CMake 无 piliplus 残留
- [ ] `flutter analyze` 0 errors
- [ ] `flutter build apk --release` 编译通过
