// 消息中心(框架级)。
//
// 聚合 回复我的 / @我的 / 收到的赞 三个消息 tab(复用各消息页,
// showAppBar: false 嵌入)。原 B站 版此处为私信列表(OttoHub 服务端
// 无私信 API,不提供)。

import 'package:flutter/material.dart';

import 'package:skf/pages/msg_feed_top/at_me/view.dart';
import 'package:skf/pages/msg_feed_top/like_me/view.dart';
import 'package:skf/pages/msg_feed_top/reply_me/view.dart';

class MsgCenterPage extends StatelessWidget {
  const MsgCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('消息'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: '回复'),
              Tab(text: '@'),
              Tab(text: '点赞'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            ReplyMePage(showAppBar: false),
            AtMePage(showAppBar: false),
            LikeMePage(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
