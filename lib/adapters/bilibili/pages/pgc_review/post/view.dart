import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class PgcReviewPostPanel extends StatefulWidget {
  const PgcReviewPostPanel({
    super.key,
    required this.name,
    required this.mediaId,
    this.reviewId,
    this.score,
    this.content,
  });

  final String name;
  final String mediaId;
  // modify
  final dynamic reviewId;
  final int? score;
  final String? content;

  @override
  State<PgcReviewPostPanel> createState() => _PgcReviewPostPanelState();
}

class _PgcReviewPostPanelState extends State<PgcReviewPostPanel> {
  late final TextEditingController _controller;
  late int _score = widget.score ?? 0;
  late final _isMod = widget.reviewId != null;
  bool _shareFeed = false;
  late bool _enablePost = _isMod;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScore(double dx) {
    setState(() {
      int index = (dx ~/ 50).clamp(0, 4);
      _enablePost = true;
      _score = index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 45,
          child: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            toolbarHeight: 45,
            title: Text(widget.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: Get.back,
              ),
              const SizedBox(width: 2),
            ],
            shape: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) =>
                  _onScore(details.localPosition.dx),
              onTapDown: (details) => _onScore(details.localPosition.dx),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) {
                    return index <= _score - 1
                        ? const Icon(
                            CustomIcons.star_favorite_solid,
                            size: 50,
                            color: Color(0xFFFFAD35),
                          )
                        : const Icon(
                            CustomIcons.star_favorite_line,
                            size: 50,
                            color: Colors.grey,
                          );
                  },
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            switch (_score) {
              1 => '很差',
              2 => '较差',
              3 => '还行',
              4 => '很好',
              5 => '佳作',
              _ => '轻触评分',
            },
            style: TextStyle(
              fontSize: 16,
              color: _score == 0
                  ? theme.colorScheme.outline
                  : const Color(0xFFFFAD35),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              maxLength: 100,
              minLines: 5,
              maxLines: 5,
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
        if (!_isMod)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: GestureDetector(
              behavior: .opaque,
              onTap: () => setState(() => _shareFeed = !_shareFeed),
              child: Row(
                mainAxisSize: .min,
                children: [
                  Icon(
                    size: 22,
                    _shareFeed
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank_outlined,
                    color: _shareFeed
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  Text(
                    ' 分享到动态',
                    style: TextStyle(
                      color: _shareFeed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 6,
            bottom:
                MediaQuery.paddingOf(context).bottom +
                MediaQuery.viewInsetsOf(context).bottom +
                6,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.onInverseSurface,
            border: Border(
              top: BorderSide(
                width: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
            onPressed: _enablePost ? _onPost : null,
            child: _isMod ? const Text('编辑') : const Text('发布'),
          ),
        ),
      ],
    );
  }

  Future<void> _onPost() async {
    if (_isMod) {
      final res = await appRead(pgcRepositoryProvider).pgcReviewMod(
        mediaId: widget.mediaId,
        score: _score * 2,
        content: _controller.text,
        reviewId: widget.reviewId,
      );
      if (res.isSuccess) {
        AppNavigator.back();
        SmartDialog.showToast('编辑成功');
      } else {
        res.toast();
      }
      return;
    }
    if (!Accounts.main.isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final res = await appRead(pgcRepositoryProvider).pgcReviewPost(
      mediaId: widget.mediaId,
      score: _score * 2,
      content: _controller.text,
      shareFeed: _isMod ? false : _shareFeed,
    );
    if (res.isSuccess) {
      AppNavigator.back();
      SmartDialog.showToast('点评成功');
    } else {
      res.toast();
    }
  }
}
