import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/common/widgets/view_safe_area.dart';
import 'package:skf/adapters/bilibili/models/common/member/search_type.dart';
import 'package:skf/adapters/bilibili/pages/member_search/child/view.dart';
import 'package:skf/adapters/bilibili/pages/member_search/controller.dart';
import 'package:flutter/material.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({super.key, required this.mid, this.uname});

  final String mid;
  final String? uname;

  @override
  State<MemberSearchPage> createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage>
    with SingleTickerProviderStateMixin {
  late final _controller = MemberSearchController(widget.mid, uname: widget.uname, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: _controller.submit,
            icon: const Icon(Icons.search, size: 22),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          focusNode: _controller.focusNode,
          controller: _controller.editingController,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: '搜索',
            visualDensity: .standard,
            border: InputBorder.none,
            suffixIcon: IconButton(
              tooltip: '清空',
              icon: const Icon(Icons.clear, size: 22),
              onPressed: _controller.onClear,
            ),
          ),
          onSubmitted: (value) => _controller.submit(),
          onChanged: (value) {
            if (value.isEmpty) {
              _controller.hasData = false;
            }
          },
        ),
      ),
      body: ViewSafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) {
                return Opacity(
                opacity: _controller.hasData ? 1 : 0,
                child: Column(
                  children: [
                    TabBar(
                      controller: _controller.tabController,
                      tabs: [
                        ListenableBuilder(
                          listenable: _controller,
                          builder: (_, _) => Tab(
                            text:
                                '视频 ${_controller.counts[0] != -1 ? _controller.counts[0] : ''}',
                          ),
                        ),
                        ListenableBuilder(
                          listenable: _controller,
                          builder: (_, _) => Tab(
                            text:
                                '动态 ${_controller.counts[1] != -1 ? _controller.counts[1] : ''}',
                          ),
                        ),
                      ],
                      onTap: (index) {
                        if (!_controller.tabController.indexIsChanging) {
                          if (index == 0) {
                            _controller.arcCtr.animateToTop();
                          } else {
                            _controller.dynCtr.animateToTop();
                          }
                        }
                      },
                    ),
                    Expanded(
                      child: tabBarView(
                        controller: _controller.tabController,
                        children: [
                          MemberSearchChildPage(
                            controller: _controller.arcCtr,
                            searchType: MemberSearchType.archive,
                          ),
                          MemberSearchChildPage(
                            controller: _controller.dynCtr,
                            searchType: MemberSearchType.dynamic,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              },
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (_, _) => _controller.hasData
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: const Alignment(0, -0.5),
                      child: Text(
                        '搜索「${_controller.uname}」的动态、视频',
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
