# spes-group3-remaining-services - Work Plan (Plan C)

## TL;DR (For humans)

**What you'll get:** 全部剩余 21 个 HTTP/gRPC 服务一次抽象完成 → 17 个新 Repository + DynamicsRepository 扩展。合并 DanmakuHttp+DmGrpc，合并 DynGrpc→DynamicsRepository。同时清理废弃文件 `grpc/view.dart`（ViewGrpc，0 调用方）。预计 ~50 个文件变更。

**Why this approach:** 一次性做完不留尾巴。极简型 repo 每个 15-25 分钟，模式固化，边际成本低。

**What it will NOT do:** 不统一 LoadingState，不写测试，不改业务逻辑。

**Effort:** XL — 19 个 Repository（含扩展现有）+ 1 个文件删除，预计 ~20h
**Risk:** Medium — 模式验证过，但大量控制器重构可能遗漏

Your next move: approve, then execute with `/start-work`.

---

> TL;DR (machine): Group 3 全集 — 17+1 Repository，~50 文件变更，1 个废弃文件删除，flutter analyze 0 errors。

## Scope
### Must have
- 17 个新 Repository 接口文件 + 17 个 B站 实现 + Bridge 注册
- 1 个已存 Repository 扩展（DynamicsRepository 加入 DynGrpc 方法）
- ~40+ 控制器重构
- **废弃文件清理**: 删除 `lib/adapters/bilibili/grpc/view.dart`（ViewGrpc，0 个调用方，仅一条注释引用），清理注释引用
- `flutter analyze` 0 errors

### Must NOT have
- ❌ 不碰 ValidateHttp（utils 内部调用，不对外暴露）
- ❌ LoadingState 统一
- ❌ 测试

### 废弃文件确认

| 文件 | 状态 | 操作 |
|------|------|------|
| `lib/adapters/bilibili/grpc/view.dart` (ViewGrpc) | **废弃** — 0 调用方，仅 `pgc/controller.dart:448` 一条注释引用 | **删除文件** + 清理注释 |
| `lib/adapters/bilibili/http/validate.dart` (ValidateHttp) | 保留 — utils 层 2 个调用方，不对外暴露 | 不动 |
| `lib/adapters/bilibili/http/loading_state.dart` | 保留 — 240+ 文件使用，有 `toast()` 方法 | 不动 |

## Verification strategy
- LSP diagnostics on each file after modification
- `flutter analyze` final pass — 0 errors

## Execution strategy
### Parallel waves
Wave 0 (废弃清理): 删除 `grpc/view.dart` + 清理注释
Wave 1 (5 个大 repo 含接口+实现+Bridge): Dynamics(+Dyn), Member, Live, Msg, Im
Wave 2 (10 个极简 repo): Danmaku(+Dm), Music, DanmakuFilter, Follow, Audio, Fan, Black, Match, Space, Download
Wave 3 (2 个中等 repo): Pgc, SponsorBlock
Wave 4 (控制器重构): 每组 3-5 个控制器，按 Repository 分组
Wave 5 (最终验证)

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 接口创建 | 无 | 实现 | 彼此 |
| 实现 + Bridge | 接口 | 控制器 | 彼此 |
| 控制器重构 | 实现 | 无 | 不同 repo 的控制器 |

## Todos

### Wave 0 — 废弃文件清理
- [x] 1. 删除 `lib/adapters/bilibili/grpc/view.dart`
- [x] 2. 清理 `pgc/controller.dart:448` 的注释引用
- [x] 3. LSP 验证 — 0 errors

### Wave 1 — P0 大 Repository（5 个）
- [x] 1. DynamicsRepository（DynamicsHttp 32 方法 + DynGrpc 2 方法 → 34 方法）
- [x] 2. MemberRepository（MemberHttp 30 方法）
- [x] 3. LiveRepository（LiveHttp 25 方法）
- [x] 4. MsgRepository（MsgHttp 24 方法）
- [x] 5. ImRepository（ImGrpc 17 方法）

### Wave 2 — 极简 Repository（10 个）
- [x] 6. DanmakuRepository（DanmakuHttp 5 + DmGrpc 2 = 7 方法）
- [x] 7. MusicRepository（MusicHttp 3 方法）
- [x] 8. DanmakuFilterRepository（DanmakuFilterHttp 3 方法）
- [x] 9. FollowRepository（FollowHttp 2 方法）
- [x] 10. AudioRepository（AudioGrpc 5 方法）
- [x] 11. FanRepository（FanHttp 1 方法）
- [x] 12. BlackRepository（BlackHttp 1 方法）
- [x] 13. MatchRepository（MatchHttp 1 方法）
- [x] 14. SpaceRepository（SpaceGrpc 2 方法）
- [x] 15. DownloadRepository（DownloadHttp 1 方法）

### Wave 3 — 中等 Repository（2 个）
- [x] 16. PgcRepository（PgcHttp 11 方法）
- [x] 17. SponsorBlockRepository（SponsorBlock 8 方法）

### Wave 4 — 控制器重构
- [x] 18. 重构 DynamicsRepository 相关控制器（~5 个）
- [x] 19. 重构 MemberRepository 相关控制器（~6 个）
- [x] 20. 重构 LiveRepository 相关控制器（~4 个）
- [x] 21. 重构 MsgRepository 相关控制器（~5 个）
- [x] 22. 重构 ImRepository 相关控制器（~8 个）
- [x] 23. 重构其余 Repository 相关文件（~15 个）

### Wave 5 — 最终验证
- [x] 24. LSP diagnostics on all changed files — 0 errors
- [x] 25. `flutter analyze` — 0 errors
- [x] 26. 代码审查

## Final verification wave
- [x] F1. LSP diagnostics — 所有修改文件 0 错误
- [x] F2. `flutter analyze` — 0 errors
- [x] F3. 导入一致性审查 — 无 `*Http`/`*Grpc` 直接引用
- [x] F4. Bridge 注册完整性 — 所有 Repo 都已注册
- [x] F5. 废弃文件确认 — `grpc/view.dart` 已删除

## Commit strategy
- Wave 0 单独 commit: `spes(014): remove dead ViewGrpc file`
- 每 3-5 个 Repository 一批做一次 commit
- 最终控制器重构做一次 commit
- 格式: `spes(013): add XxxRepository + YyyRepository`

## Success criteria
- 17 个新 Repository 接口 + 实现
- 1 个 DynamicsRepository 扩展
- Bridge 所有 Repo 注册
- ~40+ 控制器/文件不再直接 import HTTP/gRPC
- `grpc/view.dart` 已删除
- `flutter analyze`: 0 errors
