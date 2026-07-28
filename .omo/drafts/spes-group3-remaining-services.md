---
slug: spes-group3-remaining-services
status: drafting
intent: clear
pending-action: write .omo/plans/spes-group3-remaining-services.md
approach: 所有剩余 HTTP + gRPC 服务一次抽象完成。合并 DanmakuHttp + DmGrpc → DanmakuRepository，合并 DynGrpc → DynamicsRepository，跳过 ViewGrpc（废弃）、ValidateHttp（已有间接层）。
---

# Draft: spes-group3-remaining-services

## Decisions

1. **范围 = 全部 21 个服务 → 19 个 Repository**（合并 2 对，跳过 2 个）
2. **合并**: DanmakuHttp(5) + DmGrpc(2) → 1 个 DanmakuRepository；DynGrpc(2) → 归入 DynamicsRepository
3. **跳过**: ViewGrpc(废弃代码，0 引用)、ValidateHttp(仅 utils 层调用，已有间接层)
4. **LoadingState**: 延续 `_fromBili` + `core_loading` 别名模式
5. **执行顺序**: P0 大 repo → 极简 repo → 中等 repo（收益递减顺序）

## Scope IN

| # | Repository | 来源 | 方法数 | 页面引用 | 复杂度 |
|---|-----------|------|-------|---------|--------|
| 1 | DynamicsRepository | DynamicsHttp(32) + DynGrpc(2) | 34 | 19 | 🔴 大 |
| 2 | MemberRepository | MemberHttp | 30 | 25 | 🔴 大 |
| 3 | LiveRepository | LiveHttp | 25 | 14 | 🔴 大 |
| 4 | MsgRepository | MsgHttp | 24 | 16 | 🔴 大 |
| 5 | ImRepository | ImGrpc | 17 | 10 | 🔴 大 |
| 6 | PgcRepository | PgcHttp | 11 | 5 | 🟡 中 |
| 7 | SponsorBlockRepository | SponsorBlock | 8 | 4 | 🟡 中 |
| 8 | DanmakuRepository | DanmakuHttp(5) + DmGrpc(2) | 7 | 3 | 🟢 小 |
| 9 | MusicRepository | MusicHttp | 3 | 3 | 🟢 小 |
| 10 | DanmakuFilterRepository | DanmakuFilterHttp | 3 | 2 | 🟢 小 |
| 11 | FollowRepository | FollowHttp | 2 | 2 | 🟢 小 |
| 12 | AudioRepository | AudioGrpc | 5 | 1 | 🟢 小 |
| 13 | FanRepository | FanHttp | 1 | 1 | 🟢 小 |
| 14 | BlackRepository | BlackHttp | 1 | 1 | 🟢 小 |
| 15 | MatchRepository | MatchHttp | 1 | 1 | 🟢 小 |
| 16 | SpaceRepository | SpaceGrpc | 2 | 1 | 🟢 小 |
| 17 | DownloadRepository | DownloadHttp | 1 | 0 | 🟢 小 |
| 18 | DynRepository | → 归入 DynamicsRepository(#1) | — | — | — |
| 19 | DmGrpcRepository | → 归入 DanmakuRepository(#8) | — | — | — |

**总计: 17 个新 Repository 文件 + 1 个 Repository 扩展（DynamicsRepository 已含 DynGrpc）**

## Scope OUT

- ❌ ViewGrpc — 废弃代码（仅 pgc/controller.dart 一条注释引用）
- ❌ ValidateHttp — 仅 utils 层内部调用，不暴露给控制器
- ❌ LoadingState 统一
- ❌ 测试编写
- ❌ 业务逻辑变更

## Approval gate
status: awaiting-approval
