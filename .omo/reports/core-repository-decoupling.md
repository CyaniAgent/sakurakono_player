# Core/Repository 接口解耦分析报告

> 生成日期: 2026-07-24
> 分析范围: `lib/core/repository/` 全部 24 个接口文件
> 目标: 消除所有 `lib/adapters/` 的 import，使接口达到 `validate_repository.dart` 的纯净度

---

## 概览

| 指标 | 数值 |
|------|------|
| 总文件数 | 24 |
| 有 adapter import 的文件数 | 23 |
| 无 adapter import 的文件数 | 1 (`validate_repository.dart`) |
| 总 adapter import 数 | **152** |
| 非 adapter 但需关注的外部 import | 4 (`fixnum`, `protobuf`, `dio`, `common/widgets/pair.dart`) |

## Import 分类统计

| 类别 | 描述 | 计数 | 占比 |
|------|------|------|------|
| **A (gRPC)** | protobuf 生成的 `.pb.dart` 类型 | 11 | 7.2% |
| **B (模型)** | 数据模型类 (`data.dart`, `info.dart`, `model.dart` 等) | 124 | 81.6% |
| **C (工具/枚举)** | 枚举、工具函数 (`models/common/`, `utils/` 等) | 15 | 9.9% |
| **D (其他)** | 适配器内部类型 (Account, subtitle_utils) | 2 | 1.3% |

### 非 adapter 但需处理的外部依赖

| 依赖 | 使用文件 | 说明 |
|------|---------|------|
| `package:fixnum/fixnum.dart` | audio, im, reply, space | protobuf 配套的 Int64 类型 |
| `package:protobuf/protobuf.dart` | im | PbMap 类型 |
| `package:dio/dio.dart` | msg | CancelToken 类型 |
| `package:skf/common/widgets/pair.dart` | dynamics | 通用 Pair 工具类 (在 core 外) |

---

## 逐文件分析

### 1. `audio_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/grpc/bilibili/app/archive/middleware/v1.pb.dart` — **A (gRPC)**
  - `adapters/bilibili/grpc/bilibili/app/listener/v1.pb.dart` — **A (gRPC)**
  - `package:fixnum/fixnum.dart` — 外部 protobuf 依赖
- **关联 adapter 子模块**: `grpc/bilibili/app/archive/middleware/`, `grpc/bilibili/app/listener/`
- **依赖链**: 无其他 repository 依赖此接口
- **解耦方案建议**:
  - 步骤: 在 `core/` 中为 `PlayURLResp`, `PlaylistResp`, `ThumbUpResp`, `TripleLikeResp`, `CoinAddResp`, `PlaylistSource`, `PageOption`, `ListOrder`, `ThumbUpReq_ThumbType` 创建接口层包装类型或纯 Dart 替代类型
  - 涉及 core 文件变更: `audio_repository.dart` + 新建 `core/models/audio_types.dart`
  - 涉及 adapter 文件变更: `BiliAudioRepository` 实现类需适配新类型
  - 预计工作量: 3-4 天 (含 gRPC 响应类型包装)

### 2. `auth_repository.dart` — 难度: **困难**

- **Import 列表**:
  - `adapters/bilibili/models_new/login_devices/data.dart` — **B (模型)**
  - `adapters/bilibili/utils/accounts/account.dart` — **D (适配器内部类型)**
- **关联 adapter 子模块**: `models_new/login_devices/`, `utils/accounts/`
- **依赖链**: 无其他 repository 依赖此接口
- **解耦方案建议**:
  - 步骤: `Account` 类型是 Bilibili 适配器的核心概念 (sealed class with cookie jar, headers, grpc headers)，无法简单替换。需在 core 中定义抽象的 `Account` 接口或使用 `Map`/纯数据类替代。`LoginDevicesData` 模型需迁移到 core
  - 涉及 core 文件变更: `auth_repository.dart` + 新建 `core/models/account.dart` (抽象接口) + `core/models/login_devices_data.dart`
  - 涉及 adapter 文件变更: `BiliAuthRepository` + `Account` 实现类适配
  - 预计工作量: 4-5 天 (Account 类型解耦是核心难点)

### 3. `black_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models_new/blacklist/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models_new/blacklist/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 将 `BlackListData` 模型类迁移到 `core/models/`，替换 import 路径
  - 涉及 core 文件变更: `black_repository.dart` + 新建 `core/models/blacklist_data.dart`
  - 涉及 adapter 文件变更: `BiliBlackRepository` 更新 import
  - 预计工作量: 0.5 天

### 4. `danmaku_filter_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models/user/danmaku_block.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/user/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 将 `DanmakuBlockDataModel`, `SimpleRule` 迁移到 `core/models/`
  - 涉及 core 文件变更: `danmaku_filter_repository.dart` + 新建 `core/models/danmaku_block.dart`
  - 涉及 adapter 文件变更: `BiliDanmakuFilterRepository` 更新 import
  - 预计工作量: 0.5 天

### 5. `danmaku_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/grpc/bilibili/community/service/dm/v1.pb.dart` — **A (gRPC)**
  - `adapters/bilibili/models_new/danmaku/post.dart` — **B (模型)**
- **关联 adapter 子模块**: `grpc/bilibili/community/service/dm/`, `models_new/danmaku/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `DmSegMobileReply`, `DmViewReply` 是 gRPC 生成的 protobuf 类型，需在 core 中定义包装类型或纯 Dart 替代。`DanmakuPost` 模型需迁移
  - 涉及 core 文件变更: `danmaku_repository.dart` + 新建 `core/models/danmaku_types.dart`
  - 涉及 adapter 文件变更: `BiliDanmakuRepository` 适配
  - 预计工作量: 2-3 天

### 6. `download_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models_new/download/bili_download_entry_info.dart` — **B (模型)**
  - `adapters/bilibili/models_new/download/bili_download_media_file_info.dart` — **B (模型)**
- **关联 adapter 子模块**: `models_new/download/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 将 `BiliDownloadEntryInfo`, `BiliDownloadMediaInfo`, `SourceInfo`, `PageInfo`, `EpInfo` 迁移到 `core/models/`
  - 涉及 core 文件变更: `download_repository.dart` + 新建 `core/models/download_types.dart`
  - 涉及 adapter 文件变更: `BiliDownloadRepository` 更新 import
  - 预计工作量: 0.5 天

### 7. `dynamics_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/dynamic/dynamics_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/common/reply/reply_option_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/dynamics/result.dart` — **B (模型)**
  - `adapters/bilibili/models/dynamics/up.dart` — **B (模型)**
  - `adapters/bilibili/models/dynamics/vote_model.dart` — **B (模型)**
  - `adapters/bilibili/models_new/article/article_info/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/article/article_list/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/article/article_view/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/bubble/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_mention/group.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_reaction/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_reserve/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_reserve_info/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_topic_feed/topic_card_list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_topic_top/top_details.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_topic_top/topic_item.dart` — **B (模型)**
  - `adapters/bilibili/models_new/followee_votes/vote.dart` — **B (模型)**
  - `adapters/bilibili/grpc/bilibili/app/dynamic/v2.pb.dart` — **A (gRPC)**
  - `package:skf/common/widgets/pair.dart` — 非 adapter 但需关注
- **关联 adapter 子模块**: `models/dynamics/`, `models/common/dynamic/`, `models/common/reply/`, `models_new/article/`, `models_new/bubble/`, `models_new/dynamic/`, `models_new/followee_votes/`, `grpc/bilibili/app/dynamic/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 19 个 adapter import 是 24 个文件中第二多的。需将 `DynamicsTabType`, `ReplyOptionType`, `DynamicsDataModel`, `FollowUpModel`, `DynamicItemModel`, `VoteInfo`, `ArticleInfoData`, `ArticleViewData`, `ArticleListData`, `BubbleData`, `DynReactionData`, `DynReserveData`, `ReserveInfoData`, `TopicCardList`, `TopDetails`, `TopicItem`, `MentionGroup`, `FolloweeVote`, `OpusPicModel`, `OpusType`, `OpusDetailResp` 全部迁移或包装。`Pair` 类应移到 `core/` 下
  - 涉及 core 文件变更: `dynamics_repository.dart` + 新建 `core/models/dynamics/` 目录 (约 10+ 文件)
  - 涉及 adapter 文件变更: `BiliDynamicsRepository` 更新 import
  - 预计工作量: 5-7 天 (模型数量最多)

### 8. `fan_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models_new/follow/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models_new/follow/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 将 `FollowData` 迁移到 `core/models/` (注意: 此类型被 fan, follow, member, user 四个 repository 共用)
  - 涉及 core 文件变更: `fan_repository.dart` + 新建 `core/models/follow_data.dart`
  - 涉及 adapter 文件变更: 4 个实现类更新 import
  - 预计工作量: 0.5 天

### 9. `fav_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/fav_order_type.dart` — **C (枚举)**
  - `adapters/bilibili/models_new/fav/fav_article/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/fav/fav_detail/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/fav/fav_folder/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/fav/fav_folder/list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/fav/fav_note/list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/fav/fav_pgc/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/fav/fav_topic/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_cheese/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_fav/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/sub/sub_detail/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/common/fav/`, `models_new/fav/`, `models_new/space/`, `models_new/sub/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `FavOrderType` 枚举需在 core 中定义。10 个模型类需迁移。注意 `SpaceCheeseData` 也被 member_repository 使用
  - 涉及 core 文件变更: `fav_repository.dart` + 新建 `core/models/fav/` 目录 (约 10 文件)
  - 涉及 adapter 文件变更: `BiliFavRepository` 更新 import
  - 预计工作量: 3-4 天

### 10. `follow_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models_new/follow/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models_new/follow/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 与 fan_repository 共用 `FollowData`，统一迁移
  - 涉及 core 文件变更: `follow_repository.dart` + 共享 `core/models/follow_data.dart`
  - 涉及 adapter 文件变更: `BiliFollowRepository` 更新 import
  - 预计工作量: 0.5 天 (与 fan 共享)

### 11. `im_repository.dart` — 难度: **困难**

- **Import 列表**:
  - `adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart` — **A (gRPC)**
  - `adapters/bilibili/grpc/bilibili/im/interfaces/v1.pb.dart` — **A (gRPC)**
  - `adapters/bilibili/grpc/bilibili/im/type.pb.dart` — **A (gRPC)**
  - `package:fixnum/fixnum.dart` — 外部 protobuf 依赖
  - `package:protobuf/protobuf.dart` — 外部 protobuf 依赖 (PbMap)
- **关联 adapter 子模块**: `grpc/bilibili/app/im/`, `grpc/bilibili/im/interfaces/`, `grpc/bilibili/im/type/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 所有方法签名都直接使用 gRPC 生成的 protobuf 类型 (`RspSendMsg`, `RspShareList`, `RspSessionMsg`, `SessionMainReply`, `SessionSecondaryReply`, `ClearUnreadReply`, `SessionUpdateReply`, `PinSessionReply`, `UnPinSessionReply`, `DeleteSessionListReply`, `GetImSettingsReply`, `SetImSettingsReply`, `KeywordBlockingListReply`, `KeywordBlockingAddReply`, `KeywordBlockingDeleteReply`, `RspTotalUnread`, `SessionInfo`, `MsgType`, `Offset`, `SessionPageType`, `SessionId`, `IMSettingType`, `Setting`, `PbMap` 等)。这是 gRPC 耦合最深的接口，几乎所有参数和返回值都是 protobuf 类型
  - 涉及 core 文件变更: `im_repository.dart` + 新建 `core/models/im_types.dart` (大量包装类型)
  - 涉及 adapter 文件变更: `BiliImRepository` 适配新类型
  - 预计工作量: 5-7 天 (gRPC 深度耦合)

### 12. `live_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/live/live_contribution_rank_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/common/live/live_search_type.dart` — **C (枚举)**
  - `adapters/bilibili/models_new/live/live_area_list/area_item.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_area_list/area_list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_contribution_rank/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_danmaku/danmaku_msg.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_dm_block/shield_info.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_dm_block/shield_user_list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_dm_info/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_emote/datum.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_feed_index/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_follow/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_medal_wall/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_room_info_h5/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_room_play_info/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_search/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_second_list/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/live/live_superchat/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/common/live/`, `models_new/live/` (10+ 子目录)
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 2 个枚举 + 16 个模型需迁移。模型数量多但模式统一，适合批量处理
  - 涉及 core 文件变更: `live_repository.dart` + 新建 `core/models/live/` 目录 (约 18 文件)
  - 涉及 adapter 文件变更: `BiliLiveRepository` 更新 import
  - 预计工作量: 4-5 天

### 13. `match_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models_new/match/match_info/contest.dart` — **B (模型)**
- **关联 adapter 子模块**: `models_new/match/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 将 `MatchContest` 迁移到 `core/models/`
  - 涉及 core 文件变更: `match_repository.dart` + 新建 `core/models/match_contest.dart`
  - 涉及 adapter 文件变更: `BiliMatchRepository` 更新 import
  - 预计工作量: 0.5 天

### 14. `member_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/member/archive_order_type_app.dart` — **C (枚举)**
  - `adapters/bilibili/models/common/member/archive_order_type_web.dart` — **C (枚举)**
  - `adapters/bilibili/models/common/member/archive_sort_type_app.dart` — **C (枚举)**
  - `adapters/bilibili/models/common/member/contribute_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/common/member/web_ss_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/dynamics/result.dart` — **B (模型)**
  - `adapters/bilibili/models/member/info.dart` — **B (模型)**
  - `adapters/bilibili/models/member/tags.dart` — **B (模型)**
  - `adapters/bilibili/models_new/follow/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/member/coin_like_arc/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/member/search_archive/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/member/season_web/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/member_card_info/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/member_guard/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_archive/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_article/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_audio/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_cheese/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_opus/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_season_series/item.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space/space_shop/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/upower_rank/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/common/member/`, `models/dynamics/`, `models/member/`, `models_new/follow/`, `models_new/member/`, `models_new/member_card_info/`, `models_new/member_guard/`, `models_new/space/`, `models_new/upower_rank/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 23 个 adapter import 是所有文件中**最多**的。5 个枚举 + 18 个模型需迁移。注意与 dynamics_repository 共享 `DynamicsDataModel`，与 fav_repository 共享 `SpaceCheeseData`，与 fan/follow/user 共享 `FollowData`
  - 涉及 core 文件变更: `member_repository.dart` + 新建 `core/models/member/` 目录 (约 20+ 文件)
  - 涉及 adapter 文件变更: `BiliMemberRepository` 更新 import
  - 预计工作量: 5-6 天

### 15. `msg_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models_new/msg/im_user_infos/datum.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/msg_at/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/msg_dnd/uid_setting.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/msg_like/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/msg_like_detail/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/msg_reply/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/msg_sys/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msg/session_ss/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/msgfeed_unread/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/single_unread/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/upload_bfs/data.dart` — **B (模型)**
  - `package:dio/dio.dart` — 外部依赖 (CancelToken)
- **关联 adapter 子模块**: `models_new/msg/`, `models_new/msgfeed_unread/`, `models_new/single_unread/`, `models_new/upload_bfs/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 11 个模型需迁移。`CancelToken` 来自 dio，需用 core 中定义的抽象取消令牌替代
  - 涉及 core 文件变更: `msg_repository.dart` + 新建 `core/models/msg/` 目录 (约 11 文件) + `core/models/cancel_token.dart` (抽象)
  - 涉及 adapter 文件变更: `BiliMsgRepository` 更新 import
  - 预计工作量: 3-4 天

### 16. `music_repository.dart` — 难度: **简单**

- **Import 列表**:
  - `adapters/bilibili/models_new/music/bgm_detail.dart` — **B (模型)**
  - `adapters/bilibili/models_new/music/bgm_recommend_list.dart` — **B (模型)**
- **关联 adapter 子模块**: `models_new/music/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 将 `MusicDetail`, `BgmRecommend` 迁移到 `core/models/`
  - 涉及 core 文件变更: `music_repository.dart` + 新建 `core/models/music_types.dart`
  - 涉及 adapter 文件变更: `BiliMusicRepository` 更新 import
  - 预计工作量: 0.5 天

### 17. `pgc_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/pgc_review_type.dart` — **C (枚举)**
  - `adapters/bilibili/models_new/pgc/pgc_index_condition/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/pgc/pgc_index_result/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/pgc/pgc_index_result/list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/pgc/pgc_review/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/pgc/pgc_timeline/result.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/common/pgc/`, `models_new/pgc/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `PgcReviewType` 枚举需在 core 中定义。5 个模型需迁移
  - 涉及 core 文件变更: `pgc_repository.dart` + 新建 `core/models/pgc/` 目录 (约 6 文件)
  - 涉及 adapter 文件变更: `BiliPgcRepository` 更新 import
  - 预计工作量: 2 天

### 18. `reply_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart` — **A (gRPC)**
  - `package:fixnum/fixnum.dart` — 外部 protobuf 依赖
- **关联 adapter 子模块**: `grpc/bilibili/main/community/reply/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `DetailListReply`, `DialogListReply`, `MainListReply`, `Mode`, `SearchItemReply`, `SearchItemType`, `TranslateReplyResp` 都是 gRPC 类型。需在 core 中定义包装类型。`Int64` 需用 `int` 替代
  - 涉及 core 文件变更: `reply_repository.dart` + 新建 `core/models/reply_types.dart`
  - 涉及 adapter 文件变更: `BiliReplyRepository` 适配
  - 预计工作量: 2-3 天

### 19. `search_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/search/search_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/search/result.dart` — **B (模型)**
  - `adapters/bilibili/models/search/suggest.dart` — **B (模型)**
  - `adapters/bilibili/models_new/dynamic/dyn_topic_pub_search/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/pgc/pgc_info_model/result.dart` — **B (模型)**
  - `adapters/bilibili/models_new/search/search_rcmd/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/search/search_trending/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_detail/dimension.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/common/search/`, `models/search/`, `models_new/dynamic/`, `models_new/pgc/`, `models_new/search/`, `models_new/video/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `SearchType` 枚举需在 core 中定义。7 个模型需迁移。注意 `Dimension` 也被 video_repository 使用
  - 涉及 core 文件变更: `search_repository.dart` + 新建 `core/models/search/` 目录 (约 8 文件)
  - 涉及 adapter 文件变更: `BiliSearchRepository` 更新 import
  - 预计工作量: 2-3 天

### 20. `space_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/grpc/bilibili/app/dynamic/v2.pb.dart` — **A (gRPC)**
  - `adapters/bilibili/grpc/bilibili/app/interfaces/v1.pb.dart` — **A (gRPC)**
  - `package:fixnum/fixnum.dart` — 外部 protobuf 依赖
- **关联 adapter 子模块**: `grpc/bilibili/app/dynamic/`, `grpc/bilibili/app/interfaces/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `OpusSpaceFlowResp`, `SearchArchiveReply` 是 gRPC 类型。`Int64` 需用 `int` 替代
  - 涉及 core 文件变更: `space_repository.dart` + 新建 `core/models/space_types.dart`
  - 涉及 adapter 文件变更: `BiliSpaceRepository` 适配
  - 预计工作量: 2 天

### 21. `sponsor_block_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/common/sponsor_block/post_segment_model.dart` — **C (模型/枚举)**
  - `adapters/bilibili/models/common/sponsor_block/segment_type.dart` — **C (枚举)**
  - `adapters/bilibili/models_new/sponsor_block/segment_item.dart` — **B (模型)**
  - `adapters/bilibili/models_new/sponsor_block/user_info.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/common/sponsor_block/`, `models_new/sponsor_block/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: `PostSegmentModel`, `SegmentType` 枚举需在 core 中定义。`SegmentItemModel`, `UserInfo` 模型需迁移
  - 涉及 core 文件变更: `sponsor_block_repository.dart` + 新建 `core/models/sponsor_block_types.dart`
  - 涉及 adapter 文件变更: `BiliSponsorBlockRepository` 更新 import
  - 预计工作量: 1 天

### 22. `user_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/models/user/info.dart` — **B (模型)**
  - `adapters/bilibili/models/user/stat.dart` — **B (模型)**
  - `adapters/bilibili/models_new/coin_log/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/follow/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/history/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/later/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/login_log/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/media_list/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/relation/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/space_setting/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/sub/sub/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/user_real_name/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_tag/data.dart` — **B (模型)**
- **关联 adapter 子模块**: `models/user/`, `models_new/coin_log/`, `models_new/follow/`, `models_new/history/`, `models_new/later/`, `models_new/login_log/`, `models_new/media_list/`, `models_new/relation/`, `models_new/space_setting/`, `models_new/sub/`, `models_new/user_real_name/`, `models_new/video/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 13 个模型需迁移。注意 `FollowData` 被 4 个 repository 共用，`VideoTagItem` 被 video_repository 共用
  - 涉及 core 文件变更: `user_repository.dart` + 新建 `core/models/user/` 目录 (约 13 文件)
  - 涉及 adapter 文件变更: `BiliUserRepository` 更新 import
  - 预计工作量: 3-4 天

### 23. `video_repository.dart` — 难度: **中等**

- **Import 列表**:
  - `adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart` — **A (gRPC)**
  - `adapters/bilibili/models/common/video/video_type.dart` — **C (枚举)**
  - `adapters/bilibili/models/home/rcmd/result.dart` — **B (模型)**
  - `adapters/bilibili/models/model_hot_video_item.dart` — **B (模型)**
  - `adapters/bilibili/models/model_rec_video_item.dart` — **B (模型)**
  - `adapters/bilibili/models/pgc_lcf.dart` — **B (模型)**
  - `adapters/bilibili/models/video/play/url.dart` — **B (模型)**
  - `adapters/bilibili/models_new/pgc/pgc_rank/pgc_rank_item_model.dart` — **B (模型)**
  - `adapters/bilibili/models_new/popular/popular_precious/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/popular/popular_series_list/list.dart` — **B (模型)**
  - `adapters/bilibili/models_new/popular/popular_series_one/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/triple/pgc_triple.dart` — **B (模型)**
  - `adapters/bilibili/models_new/triple/ugc_triple.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_ai_conclusion/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_detail/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_note_list/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_play_info/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_relation/data.dart` — **B (模型)**
  - `adapters/bilibili/models_new/video/video_shot/data.dart` — **B (模型)**
  - `adapters/bilibili/utils/subtitle_utils.dart` — **D (工具函数)**
- **关联 adapter 子模块**: `grpc/bilibili/main/community/reply/`, `models/common/video/`, `models/home/rcmd/`, `models/`, `models/video/play/`, `models_new/pgc/`, `models_new/popular/`, `models_new/triple/`, `models_new/video/`, `utils/`
- **依赖链**: 无
- **解耦方案建议**:
  - 步骤: 20 个 adapter import。`ReplyInfo` (gRPC) 需包装。`VideoType` 枚举需在 core 中定义。17 个模型需迁移。`SubtitleFormat` 枚举和 `subtitle_utils.dart` 中的工具函数需在 core 中定义替代
  - 涉及 core 文件变更: `video_repository.dart` + 新建 `core/models/video/` 目录 (约 18 文件) + `core/utils/subtitle_utils.dart`
  - 涉及 adapter 文件变更: `BiliVideoRepository` 更新 import
  - 预计工作量: 5-6 天

### 24. `validate_repository.dart` — 难度: **无 (参考范例)**

- **Import 列表**:
  - `package:skf/core/result/loading_state.dart` — **纯 core 依赖**
- **为什么没有 adapter import**: 该接口只使用 `LoadingState<Map?>` 和 `dynamic` 作为参数/返回值类型，完全不依赖任何 Bilibili 特有的模型或枚举。所有参数都是基础 Dart 类型 (`String`, `dynamic`)
- **对其他文件的启示**: 这是所有 repository 接口的目标状态。关键模式是: 使用 `Map?` / `dynamic` / 基础类型作为参数和返回值，避免引入 adapter 特有的类型

---

## 建议解耦顺序

### 第一批 (简单 — 可并行执行)

这些文件只依赖模型类 (Category B)，只需将模型迁移到 `core/models/` 并替换 import 路径。**预计总工作量: 3 天**

| 文件 | 模型数 | 优先级 |
|------|--------|--------|
| `black_repository.dart` | 1 (`BlackListData`) | 🔴 高 |
| `danmaku_filter_repository.dart` | 1 (`DanmakuBlockDataModel`, `SimpleRule`) | 🔴 高 |
| `download_repository.dart` | 2 (`BiliDownloadEntryInfo`, `BiliDownloadMediaInfo`) | 🔴 高 |
| `fan_repository.dart` | 1 (`FollowData`) — 注意共享 | 🔴 高 |
| `follow_repository.dart` | 1 (`FollowData`) — 注意共享 | 🔴 高 |
| `match_repository.dart` | 1 (`MatchContest`) | 🟡 中 |
| `music_repository.dart` | 2 (`MusicDetail`, `BgmRecommend`) | 🟡 中 |

**关键依赖**: `FollowData` 被 fan, follow, member, user 四个 repository 共用，应最先迁移到 `core/models/follow_data.dart`。

### 第二批 (中等 — 需创建 core 类型)

这些文件包含枚举 (Category C) 或 gRPC 类型 (Category A)，需要在 core 中定义替代类型/包装类型。**预计总工作量: 15-20 天**

| 文件 | 需处理的内容 | 优先级 |
|------|-------------|--------|
| `pgc_repository.dart` | 1 枚举 + 5 模型 | 🟡 中 |
| `sponsor_block_repository.dart` | 2 枚举 + 2 模型 | 🟡 中 |
| `search_repository.dart` | 1 枚举 + 7 模型 | 🟡 中 |
| `space_repository.dart` | 2 gRPC 类型 | 🟡 中 |
| `reply_repository.dart` | 1 gRPC 类型 | 🟡 中 |
| `fav_repository.dart` | 1 枚举 + 10 模型 | 🟡 中 |
| `msg_repository.dart` | 11 模型 + dio CancelToken | 🟡 中 |
| `user_repository.dart` | 13 模型 | 🟡 中 |
| `danmaku_repository.dart` | 1 gRPC + 1 模型 | 🟡 中 |
| `audio_repository.dart` | 2 gRPC 类型 | 🟡 中 |
| `live_repository.dart` | 2 枚举 + 16 模型 | 🟢 低 |
| `video_repository.dart` | 1 gRPC + 1 枚举 + 1 util + 17 模型 | 🟢 低 |
| `member_repository.dart` | 5 枚举 + 18 模型 | 🟢 低 |
| `dynamics_repository.dart` | 2 枚举 + 1 gRPC + 14 模型 | 🟢 低 |

### 第三批 (困难 — 需重构接口)

这些文件深度耦合了 adapter 内部概念，需要重新设计接口签名。**预计总工作量: 10-12 天**

| 文件 | 难点 | 优先级 |
|------|------|--------|
| `auth_repository.dart` | `Account` 类型是 adapter 核心概念，需在 core 中定义抽象接口 | 🟡 中 |
| `im_repository.dart` | 所有方法签名都使用 gRPC protobuf 类型，需大量包装 | 🟢 低 |

---

## 关键发现

### 1. 模型共享模式
多个 repository 共用同一模型类，迁移时需统一处理:

| 模型 | 被以下文件共用 |
|------|--------------|
| `FollowData` | fan, follow, member, user (4 个) |
| `DynamicsDataModel` | dynamics, member (2 个) |
| `SpaceCheeseData` | fav, member (2 个) |
| `Dimension` | search, video (2 个) |
| `VideoTagItem` | user, video (2 个) |

### 2. gRPC 耦合分布
11 个 gRPC import 分布在 7 个文件中，其中 `im_repository.dart` (3 个) 和 `audio_repository.dart` (2 个) 耦合最深。gRPC 类型需要包装层，因为 protobuf 生成的类无法直接移到 core。

### 3. 枚举迁移模式
15 个枚举 import 分布在 8 个文件中。枚举通常定义简单，可以直接在 core 中重新定义，不需要迁移 adapter 中的原始定义（但 adapter 实现类需要适配）。

### 4. 外部依赖处理
- `fixnum` (Int64): 用于 audio, im, reply, space。解耦后应全部替换为 `int`
- `protobuf` (PbMap): 仅 im 使用。需在 core 中定义替代的 Map 类型
- `dio` (CancelToken): 仅 msg 使用。需在 core 中定义抽象的取消令牌接口
- `Pair` (common/widgets): 仅 dynamics 使用。应移到 `core/utils/pair.dart`

### 5. 按 adapter 子模块统计 import 热度

| adapter 子模块 | 被引用次数 | 涉及文件 |
|---------------|-----------|---------|
| `models_new/video/` | 7 | search, user, video |
| `models_new/live/` | 16 | live |
| `models_new/dynamic/` | 6 | dynamics |
| `models_new/follow/` | 4 | fan, follow, member, user |
| `models_new/space/` | 8 | fav, member |
| `models_new/pgc/` | 5 | pgc, search, video |
| `models_new/member/` | 3 | member |
| `models_new/msg/` | 8 | msg |
| `models_new/fav/` | 7 | fav |
| `models_new/popular/` | 3 | video |
| `models_new/triple/` | 2 | video |
| `models_new/search/` | 2 | search |
| `models_new/download/` | 2 | download |
| `models_new/music/` | 2 | music |
| `models_new/match/` | 1 | match |
| `models_new/blacklist/` | 1 | black |
| `models_new/sponsor_block/` | 2 | sponsor_block |
| `models_new/bubble/` | 1 | dynamics |
| `models_new/followee_votes/` | 1 | dynamics |
| `models_new/article/` | 3 | dynamics |
| `models_new/sub/` | 2 | fav, user |
| `models_new/coin_log/` | 1 | user |
| `models_new/history/` | 1 | user |
| `models_new/later/` | 1 | user |
| `models_new/login_log/` | 1 | user |
| `models_new/media_list/` | 1 | user |
| `models_new/relation/` | 1 | user |
| `models_new/space_setting/` | 1 | user |
| `models_new/user_real_name/` | 1 | user |
| `models_new/upload_bfs/` | 1 | msg |
| `models_new/msgfeed_unread/` | 1 | msg |
| `models_new/single_unread/` | 1 | msg |
| `models_new/member_card_info/` | 1 | member |
| `models_new/member_guard/` | 1 | member |
| `models_new/upower_rank/` | 1 | member |
| `models_new/login_devices/` | 1 | auth |
| `models_new/danmaku/` | 1 | danmaku |
| `models/common/` (枚举) | 15 | 8 个文件 |
| `models/` (旧模型) | 8 | dynamics, member, search, video |
| `grpc/` | 11 | 7 个文件 |
| `utils/` | 2 | auth, video |

### 6. 总体工作量估算

| 批次 | 文件数 | 预计总工作量 |
|------|--------|------------|
| 第一批 (简单) | 7 | 3 天 |
| 第二批 (中等) | 14 | 15-20 天 |
| 第三批 (困难) | 2 | 10-12 天 |
| **合计** | **23** | **28-35 天** |

### 7. 建议执行策略

1. **先迁移共享模型**: `FollowData` 是最高优先级的共享模型，迁移后可以解锁 4 个 repository
2. **并行处理第一批**: 7 个简单文件可以并行执行，快速见效
3. **枚举先行**: 8 个文件中的 15 个枚举可以批量在 core 中定义，然后逐个文件切换
4. **gRPC 包装层统一设计**: 7 个使用 gRPC 的文件需要统一的包装类型设计模式，建议先设计好包装层方案再逐个实施
5. **最后攻坚**: `auth_repository.dart` (Account 解耦) 和 `im_repository.dart` (gRPC 深度耦合) 留到最后处理

---

## 附录: 非 adapter import 统计

| Import | 文件 | 说明 |
|--------|------|------|
| `package:fixnum/fixnum.dart` | audio, im, reply, space | protobuf Int64 — 解耦后替换为 `int` |
| `package:protobuf/protobuf.dart` | im | PbMap — 解耦后替换为 `Map` |
| `package:dio/dio.dart` | msg | CancelToken — 需 core 抽象 |
| `package:skf/common/widgets/pair.dart` | dynamics | Pair 工具类 — 应移到 `core/utils/` |
| `package:flutter/material.dart` | search | ValueChanged — 可保留 (Flutter SDK) |
| `package:flutter/foundation.dart` | (validate 等) | 可保留 (Flutter SDK) |