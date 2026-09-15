# SKF 去 B 站化 + 标准抽象接口层(执行方案 v3)

## 目标架构

```
lib/
├── core/
│   ├── contract/          # ★ 新增:标准抽象接口层(唯一标准面,全 dartdoc)
│   │   ├── player/        # 播放器主接口 + 能力接口(见下表)
│   │   ├── space/member_host.dart
│   │   ├── dynamics/dynamics_host.dart
│   │   ├── main/main_host.dart  setting/setting_host.dart
│   │   ├── mine/mine_actions.dart  download/download_capability.dart
│   │   └── capabilities.dart    # PlayerCapabilities 能力声明
│   ├── models/ repository/ adapter/ account/ utils/ result/   # 净化后
├── adapters/
│   ├── bilibili/   # 删除
│   ├── ottohub/    # 唯一真实适配器
│   └── example/    # ExampleAdapter 骨架(新适配器开发模板)
├── pages/ common/ player/ router/ utils/
```

**能力模式**:页面只依赖 `core/contract`;可选能力以 nullable getter 声明(如 `SegmentSkipCapability? get segmentSkip`),返回 null = 不支持,页面自动降级不渲染该面板。**禁止** pages 直接 import 任何适配器。

## Phase 0 — 快照
git init → 全量 commit "pre-removal snapshot"。

## Phase 1 — 上收共享件(bilibili 仍在,保证可编译)
| 来源(bilibili) | 去向 |
|---|---|
| pages/rcmd/{controller,view}.dart | lib/pages/rcmd/ |
| common/widgets/video_card/{video_card_v,video_card_h}.dart | lib/common/widgets/video_card/ |
| common/setting_providers.dart | lib/pages/providers.dart |
| services/download/download_service.dart | lib/pages/download/download_service.dart |
| pages/about/view.dart、pages/webview/view.dart、pages/hot/{view,controller}.dart | lib/pages/{about,webview,hot}/ |
| models_new/space/space_opus/{cover,item,stat}.dart | lib/adapters/ottohub/models/ |
| utils/page_utils.dart 的 toVideoPage | OttoVideoHost 自建精简版 |

## Phase 2 — 标准抽象接口层(本次核心增量)

`lib/core/contract/player/` 接口与方法级清单(从现有 VideoHost 拆分):

**video_player_host.dart — VideoPlayerHost(必需,~28 方法)**:acquirePlayer / playerSetDataSource / setPlayCallBack / playerMakeHeartBeat / updatePlayCount / buildPlayer / buildPlayerOverlays / buildKeyboardFocus / showSettingSheet / onVideoDetailDispose / videoTitle / handleShutdownTimer / buildLocalIntroPanel / buildUgcIntroPanel / buildRelatedPanel / buildReplyPanel / buildReplyTabLabel / animateReplyToTop / nextPlay / viewLater / showShootDanmakuSheet / setPlayerDanmakuVisible / toggleDanmakuEnabled / dmStateContains / startIntroTimer / cancelIntroTimer / disposeIntro / isFileSourceSource + fileEntryInfo。全部写 dartdoc(语义/参数/错误行为)。

**能力接口(可选,各 ≤12 方法)**:
| 文件 | 接口 | 方法 |
|---|---|---|
| segment_skip_capability.dart | SegmentSkipCapability | initSkip / handleSBData / querySponsorBlock / onAddItem / onRemoveItem / onSkip / getFirstSegment / buildItem / resetBlock / cancelBlockListener / onBlock / showSBDetail(+VideoBlock 模型) |
| series_capability.dart | SeriesCapability | buildPgcIntroPage(→buildSeriesIntroPage) / buildSeasonPanel / shouldShowSeasonPanel / applyClipInfo / onChangeEpisodeFromMedia |
| playlist_capability.dart | PlaylistCapability | showMediaListPanel / isPlayAllSource |
| notes_capability.dart | NotesCapability | showNoteList |
| audio_mode_capability.dart | AudioModeCapability | openAudioPage |
| interactive_capability.dart | InteractiveCapability | getSteinEdgeInfo / isSteinGate |
| subtitle_capability.dart | SubtitleCapability | fetchDmSubtitles(中立签名) |
| danmaku_capability.dart | DanmakuTrendCapability | fetchDmTrend(中立签名) |
| download_capability.dart | DownloadPanelCapability | showDownloadPanel |
| playback_source_capability.dart | PlaybackSourceCapability | selectPlayback(CorePlaybackConfig) / applyContinuePlayingPart / sourceType 三方法(中立枚举) |

**capabilities.dart**:`abstract class PlayerCapabilities` 含上表全部 nullable getter。`VideoHost` 变为 `VideoPlayerHost + PlayerCapabilities` 的组合门面(BiliVideoHost/OttoVideoHost/ExampleVideoHost 各自实现)。

**其余 Host 标准化**(单接口,方法级删减见 Phase 5):member_host / dynamics_host / main_host / setting_host / mine_actions / download_actions,每个方法 dartdoc 化。

**示例**:ExampleAdapter 全 no-op 实现 + 逐接口注释"实现此接口需要……";BiliVideoHost 声明全部能力,OttoVideoHost 仅播放主接口。

## Phase 3 — 机械删除
- 删 `lib/adapters/bilibili/`(982 文件)、`lib/grpc/bilibili/`、`dimension_ext.dart`、`test/adapters/bilibili/`、`test/helpers/bili_bootstrap.dart`、play_input_test
- adapters.dart 移除 BiliAdapter;main.dart 默认 ADAPTER=ottohub;search_types 删 bili_user
- 配置:analysis_options/build.yaml/launch.json/linux_x64.yml 描述/AndroidManifest(bilibili hosts+scheme+b23.tv)/shortcuts.xml/iOS Info.plist/ottohub_analyze 正名
- pubspec 删 B 站专属依赖(protobuf/dio_http2_adapter/http2/brotli/super_sliver_list/waterfall_flow/chat_bottom_container/flutter_sortable_wrap/live_photo_maker/dlna_dart/web_socket_channel,逐个复核)+ paycoins/live assets

## Phase 4 — 路由表(68 → 46 条)
OttoBridge 保留:/home /hot /videoV /webview /setting /fav /favDetail /later /history /search /searchResult /dynamics /dynamicDetail /follow /fan /member /blackListPage /colorSetting /fontSizeSetting /displayModeSetting /playSpeedSet /favSearch /historySearch /laterSearch /followSearch /whisper /whisperDetail /replyMe /atMe /likeMe /sysMsg /whisperSettings /loginPage /logs /settingsSearch /barSetting /createFav /editProfile /followed /sameFollowing /download /myReply /mainReply /msgLikeDetail /danmakuBlock /sponsorBlock
删除(B 站专属页随目录消失,能力接口仍在):/liveRoom /memberSearch /articlePage /articleList /subscription /subDetail /dynTopic /dynTopicRcmd /upowerRank /spaceSetting /matchInfo /musicDetail /popularSeries /popularPrecious /audio /videoWeb /ssWeb /memberGuard /bubble /createVote /liveDmBlockPage /memberDynamics

## Phase 5 — core/models 与 repository 净化
**删 repo(8 接口 + OttoHub 实现)**:live、match、music、audio、danmaku_filter、validate、pgc(→ series 域并入 Video)、space(gRPC 包装,searchArchive 并入 Search);black 并入 follow。repo 26→17。
**core/models**:
- 删:space_types、match_contest、music_types、audio_types、live_types
- member_types.dart(3395 行)→ ≤400 行:CoreSpaceProfile{mid,name,face,sign,level,fans,followCount} / CoreSpaceTab{param,title} / CoreSpaceContent;删充电/舰团/课程/漫画/挂件/勋章/装扮/Upower;CoreMemberCardInfoData{coreCard,card} 合一
- 画质/音质:B 站 qn 码与 302xx 码 → 中立枚举 CoreVideoQuality{height,desc}/CoreAudioQuality{bandwidth,desc},适配器映射
- pgc_types → series_types(Season/Episode);dynamics_types 删 Upower/Blocked;user_types 删 vip 系列字段

## Phase 6 — pages 与 storage 去 B 站化
- member/user_info_card:删充电/大航海/勋章行;member/controller:B 站 fallback tabs 改通用(动态/投稿/收藏)
- mine:删无痕模式、vipNameColor、msgBadge B 站域;video:删 CDN/试看调用点;fav:专栏/话题/课程 tab 删
- 删纯 B 站框架页:直播/赛事/音乐区相关 pages;番剧页改通用系列页
- storage_key/pref 删:p1080、preferCodecs、enableHA、CDNService、disableAudioCDN、enableOnlineTotal、superChatType、fullScreenSCWidth、audioPlayMode、showVipDanmaku、enableAi、coinWithLike、liveQuality×2、liveStream、liveCdnUrl、enableCommAntifraud、enableCreateDynAntifraud、memberTab、showMemberShop、appRcmd、minDurationForRcmd、minPlayForRcmd、minLikeRatioForRecommend、exemptFilterForFollowed、savedRcmdTip、banWordForRecommend/Reply/Zone/Dyn、msgBadgeMode、msgUnReadTypeV2、dynamicBadgeMode、showPgcTimeline、showViewPoints、showDecorate、showMedal、enableQuickFav、quickFavId、buvid、historyPause、danmakuFilterRules;画质/音质键挂中立枚举;对应设置页 UI 条目逐个删

## Phase 7 — 验证与文档
1. flutter analyze 0/0;flutter test 全绿(mocks 重跑 build_runner;被删 repo 的 ottohub 用例删除)
2. MCP 冒烟(ADAPTER=ottohub,重启调试会话):首页推荐/搜索/设置(音视频设置不崩)/密码登录(OttoAuth)/我的页
3. AGENTS.md 全系重写(utils init 顺序改 OttoAdapter 路径等);example/AGENTS.md 写"如何实现标准接口"指南
4. 移除 MCP-DEBUG 临时日志(在被删文件中的随删除消失)

## 风险与回退
每 Phase 独立 commit;Phase 2(契约层)先行使 bilibili/OttoHub 同步实现新接口并保持编译,删除时无二次重构;Phase 5/6 靠 analyze 清点消费点;OttoHub 桩位(播放器装配/用户页 tab/动态 tab/各能力实现)是模板预期边界。