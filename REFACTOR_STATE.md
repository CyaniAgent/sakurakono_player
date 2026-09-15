# SKF 去 B 站化重构 — 进度状态(供跨会话续作)

## 已完成(commit 历史即记录)
- bb7d917 快照 / 62f4781 Phase1 上收 / 6fadd73 Phase2 契约层+ExampleAdapter
- 630ff32 Phase3 删除 bilibili(982文件) / 90f3a7c Phase4 OttoBridge 28路由
- fix(ottohub) 首页 sliver 崩溃 + appRcmd 模型错乱 + 设置页菜单注入
- 验证:analyze 0/0,test 224 全绿,OttoHub Windows 启动冒烟通过(首页推荐流真实数据)

## 剩余工作(按序)
1. member_types.dart(3395行)重造为中立形状(≤400行):
   CoreSpaceProfile/CoreSpaceTab;删充电(coreElec)/舰团(coreGuard)/课程/漫画/挂件/勋章/装扮/Upower;
   CoreMemberCardInfoData{coreCard,card} 双字段合一为 card。
   消费方:lib/pages/member/{controller,view,member_host,widget/user_info_card}.dart
   + lib/adapters/ottohub/repository/otto_member_repository.dart
2. repo 瘦身:删 core/repository/{live,match,music,audio,danmaku_filter,validate,space,pgc}_repository.dart
   + core/models/{live_types,match_contest,music_types,audio_types,space_types,pgc_types}.dart
   + lib/adapters/ottohub/repository/otto_{live,match,music,audio,danmaku_filter,validate,space,pgc}_repository.dart
   + otto_bridge 对应 override 行 + repository_providers(_batch2).dart 对应 provider 行。
   注意:BLACK 保留(黑名单页在用);sponsor_block 保留(用户点名);danmaku 保留。
3. storage 清理:storage_key.dart/storage_pref.dart 删 B 站专属键
   (p1080,preferCodecs,enableHA,CDNService,disableAudioCDN,enableOnlineTotal,superChatType,
   fullScreenSCWidth,audioPlayMode,showVipDanmaku,enableAi,coinWithLike,liveQuality*2,liveStream,
   liveCdnUrl,enableCommAntifraud,enableCreateDynAntifraud,memberTab,showMemberShop,appRcmd,
   minDurationForRcmd,minPlayForRcmd,minLikeRatioForRecommend,exemptFilterForFollowed,
   banWordForRecommend/Reply/Zone/Dyn,msgBadgeMode,msgUnReadTypeV2,dynamicBadgeMode,
   showPgcTimeline,showViewPoints,showDecorate,showMedal,enableQuickFav,quickFavId,buvid)
   + storage_pref 对应 getter + 消费点。
   保留:enableSaveLastData/savedRcmdTip/recommendCardWidth(rcmd在用)、主题/窗口/字幕/播放器行为类。
4. AGENTS.md 全系重写:根(新架构:core/contract 能力模式、OttoHub+Example 双适配器、
   测试 224、init 顺序无 BiliBridge)+ utils + pages + player + core + common + ottohub + example(新)。
   删 lib/adapters/bilibili/AGENTS.md(已随目录删除?确认)。
5. 收尾:移除 MCP-DEBUG(应为0,bilibili文件已删,验证即可)、analyze 0/0、test、
   重启 ottohub app 冒烟、最终 commit。

## 约束
- 每阶段独立 commit;任一阶段失败回退上一 commit。
- analyze 必须 0 错误 0 警告;test 全绿。
- 用户要求 9:00 UTC+8 前全部完成(当前约 01:20)。
