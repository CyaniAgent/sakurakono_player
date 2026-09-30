// 消息页(框架级):私信会话列表——piliplus 时代 OttoHub 的形态。
//
// - 窄屏:会话列表,点击进入 /whisperDetail 整页会话;
// - 宽屏(>=800):左侧 320px 会话列表 + 右侧聊天面板双栏;
// - AppBar 常驻「添加好友」入口(按 UID 查用户,发私信建立会话);
// - 分页:服务端 num 上限 12,滚动到底自动加载更多;
// - 打开/离开页面与选中会话时广播未读刷新信号(mine 页徽章监听)。

import 'package:flutter/material.dart';

import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/msg_feed_top/add_friend_dialog.dart';
import 'package:skf/pages/msg_feed_top/whisper_chat_panel.dart';
import 'package:skf/router/app_navigator.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  /// 未读数刷新信号:会话页打开/离开/选中会话后自增,
  /// mine 页徽章等监听后重查 getTotalUnread。
  static final unreadRefresh = ValueNotifier<int>(0);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _controller = _MessageController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.load();
    MessagePage.unreadRefresh.value++;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    MessagePage.unreadRefresh.value++;
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      _controller.loadMore();
    }
  }

  void _openChat(CoreImFriend friend) {
    MessagePage.unreadRefresh.value++;
    AppNavigator.toNamed(
      '/whisperDetail?uid=${friend.uid}'
      '&name=${Uri.encodeComponent(friend.username)}'
      '&face=${Uri.encodeComponent(friend.avatarUrl ?? '')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AddFriendDialog(),
            ),
            icon: const Icon(Icons.person_add),
            tooltip: '添加好友',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (!isWide) return _buildListPanel(theme);
          return Row(
            children: <Widget>[
              SizedBox(width: 320, child: _buildListPanel(theme)),
              Container(
                width: 1,
                color: theme.colorScheme.outlineVariant.withAlpha(50),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final friend = _controller.selected;
                    if (friend == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: .center,
                          children: <Widget>[
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '选择一个对话开始聊天',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return WhisperChatPanel(
                      key: ValueKey(friend.uid),
                      uid: friend.uid,
                      name: friend.username,
                      face: friend.avatarUrl,
                      showHeader: true,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListPanel(ThemeData theme) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.loading && _controller.friends.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.error != null && _controller.friends.isEmpty) {
          return HttpError(
            isSliver: false,
            errMsg: _controller.error,
            onReload: () => _controller.load(refresh: true),
          );
        }
        if (_controller.friends.isEmpty) {
          return const Center(child: Text('暂无消息'));
        }
        return RefreshIndicator(
          onRefresh: () => _controller.load(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _controller.friends.length,
            itemBuilder: (context, index) =>
                _buildFriendItem(_controller.friends[index], theme),
          ),
        );
      },
    );
  }

  Widget _buildFriendItem(CoreImFriend friend, ThemeData theme) {
    final isWide = MediaQuery.widthOf(context) >= 800;
    final unread = friend.newMessageNum ?? 0;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final isSelected = _controller.selected?.uid == friend.uid;
        return Container(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withAlpha(100)
              : null,
          child: ListTile(
            onTap: () {
              if (isWide) {
                MessagePage.unreadRefresh.value++;
                _controller.select(friend);
              } else {
                _openChat(friend);
              }
            },
            leading: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: NetworkImgLayer(
                src: friend.avatarUrl,
                width: 48,
                height: 48,
                type: .avatar,
              ),
            ),
            title: Text(
              friend.username,
              maxLines: 1,
              overflow: .ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: friend.lastMessage == null
                ? null
                : Text(
                    friend.lastMessage!,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
            trailing: friend.lastTime == null
                ? null
                : Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .end,
                    children: <Widget>[
                      Text(
                        _formatTime(friend.lastTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (unread > 0) ...<Widget>[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      final difference = DateTime.now().difference(dateTime);
      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:'
            '${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      }
      return '${dateTime.month}/${dateTime.day}';
    } catch (_) {
      return time;
    }
  }
}

class _MessageController extends ChangeNotifier {
  final friends = <CoreImFriend>[];

  bool loading = false;
  bool loadingMore = false;
  String? error;
  CoreImFriend? selected;

  int _offset = 0;
  bool _hasMore = true;

  /// 服务端 friend_list 的 num 上限 12。
  static const int _pageSize = 12;

  Future<void> load({bool refresh = false}) async {
    if (loading) return;
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      error = null;
    }
    loading = true;
    notifyListeners();
    final res = await appRead(imRepositoryProvider).friendList(
      offset: _offset,
      num: _pageSize,
    );
    loading = false;
    if (res case Success(:final response)) {
      if (refresh) friends.clear();
      friends.addAll(response);
      _offset += response.length;
      if (response.length < _pageSize) _hasMore = false;
    } else if (friends.isEmpty) {
      error = (res as Error).errMsg;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !_hasMore) return;
    loadingMore = true;
    final res = await appRead(imRepositoryProvider).friendList(
      offset: _offset,
      num: _pageSize,
    );
    loadingMore = false;
    if (res case Success(:final response)) {
      friends.addAll(response);
      _offset += response.length;
      if (response.length < _pageSize) _hasMore = false;
      notifyListeners();
    }
  }

  void select(CoreImFriend friend) {
    selected = friend;
    notifyListeners();
  }
}
