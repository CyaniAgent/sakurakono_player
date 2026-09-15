# SKF 去 B 站化重构 — 进度状态(供跨会话续作)

## 已完成(commit 历史即记录)
- bb7d917 快照 / 62f4781 Phase1 上收 / 6fadd73 Phase2 契约层+ExampleAdapter
- 630ff32 Phase3 删除 bilibili(982文件) / 90f3a7c Phase4 OttoBridge 28路由
- fix(ottohub) 首页 sliver 崩溃 + appRcmd 模型错乱 + 设置页菜单注入
- 验证:analyze 0/0,test 224 全绿,OttoHub Windows 启动冒烟通过(首页推荐流真实数据)

## 全部完成(2026-09-16)

- Phase 5 repo 瘦身:26→18,删除 8 个 B 站域接口/实现/模型/provider
  (space_types 保留:member.spaceOpus 为 ottohub 真实能力 oldBlog API)
- Phase 6 member UI 去 B 站化(-290 行):充电/大航海/勋章/登录设备/硬币/经验日志/
  举报/快捷方式/空间设置 全部移除;MemberHost 同步瘦身
- Phase 6 storage:删除 31 个 B 站专属键 + getter(historyPause 为通用功能已恢复)
- Phase 7 文档:根 AGENTS.md 重写 + 子文件修补 + example/AGENTS.md 新适配器指南

## 真正的遗留路线图(后续会话)

1. member_types.dart 深度重造(3395 行 B 站形状,充电/舰团字段仍在模型层)
2. 画质/音质码值中立化(qn/302xx → 分辨率/带宽描述)
3. OttoVideoHost.buildPlayer 播放器装配实现(最大功能缺口)
4. MemberHost.buildTab 用户页 tab 内容、DynamicsHost.buildTabPage 动态 tab
5. 登录 UI(密码登录 + 扫码;OttoAuth.loginByPassword 已就绪)

## 约束
- 每阶段独立 commit;任一阶段失败回退上一 commit。
- analyze 必须 0 错误 0 警告;test 全绿。
- 用户要求 9:00 UTC+8 前全部完成(当前约 01:20)。
