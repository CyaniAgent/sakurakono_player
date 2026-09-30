// 用户私信聊天页(/whisperDetail?uid=&name=)。
//
// 整页壳:Scaffold + 顶部对方信息 AppBar;聊天主体复用框架
// WhisperChatPanel(消息页宽屏右栏同款)。

import 'package:flutter/material.dart';

import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/pages/msg_feed_top/whisper_chat_panel.dart';

class WhisperDetailPage extends StatelessWidget {
  const WhisperDetailPage({
    super.key,
    required this.uid,
    this.name,
    this.face,
  });

  final int uid;
  final String? name;
  final String? face;

  static WhisperDetailPage fromQuery(Map<String, String?> params) =>
      WhisperDetailPage(
        uid: int.tryParse(params['uid'] ?? params['talkerId'] ?? '') ?? 0,
        name: params['name'],
        face: params['face'],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: .min,
          children: [
            NetworkImgLayer(
              src: face,
              width: 34,
              height: 34,
              type: .avatar,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                name ?? '私信',
                maxLines: 1,
                overflow: .ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: WhisperChatPanel(uid: uid, name: name, face: face),
    );
  }
}
