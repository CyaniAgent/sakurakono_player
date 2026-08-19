import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/common/widgets/dialog/export_import.dart';
import 'package:skf/common/widgets/disabled_icon.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/sliver_wrap.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/search/controller.dart';
import 'package:skf/pages/search/widgets/hot_keyword.dart';
import 'package:skf/pages/search/widgets/search_text.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/em.dart' show Em;
import 'package:skf/utils/extension/size_ext.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/utils.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _tag = Utils.generateRandomString(6);
  late ThemeData theme;
  late bool isPortrait;
  late EdgeInsets padding;

  SSearchParams get _params => (
        tag: _tag,
        hintText: _getHintText(),
        text: _getText(),
      );

  String? _getHintText() {
    final route = ModalRoute.of(context);
    if (route?.settings.arguments is Map) {
      return (route!.settings.arguments as Map)['hintText'] as String?;
    }
    return null;
  }

  String? _getText() {
    final route = ModalRoute.of(context);
    if (route?.settings.arguments is Map) {
      return (route!.settings.arguments as Map)['text'] as String?;
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
    padding = MediaQuery.viewPaddingOf(context);
    isPortrait = MediaQuery.sizeOf(context).isPortrait;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.watch(sSearchProvider(_params));

    final trending =
        ctrl.enableTrending ? _buildHotSearch(ctrl) : null;
    final rcmd = ctrl.enableSearchRcmd
        ? _buildHotSearch(ctrl, isTrending: false)
        : null;

    return Scaffold(
      appBar: _buildAppBar(ctrl),
      body: Padding(
        padding: .only(left: padding.left, right: padding.right),
        child: CustomScrollView(
          slivers: [
            if (ctrl.searchSuggestion) _buildSearchSuggest(ctrl),
            if (isPortrait) ...[
              ?trending,
              _buildHistory(ctrl),
              ?rcmd,
            ] else if (ctrl.enableTrending || ctrl.enableSearchRcmd)
              SliverCrossAxisGroup(
                slivers: [
                  SliverMainAxisGroup(slivers: [?trending, ?rcmd]),
                  _buildHistory(ctrl),
                ],
              )
            else
              _buildHistory(ctrl),
            SliverPadding(padding: .only(bottom: padding.bottom)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SSearchController ctrl) => AppBar(
    shape: Border(
      bottom: BorderSide(
        color: theme.dividerColor.withValues(alpha: 0.08),
        width: 1,
      ),
    ),
    actions: [
      if (ctrl.showUidBtn)
        IconButton(
          tooltip: 'UID搜索用户',
          icon: const Icon(Icons.person_outline, size: 22),
          onPressed: () => AppNavigator.toNamed(
            '/member?mid=${ctrl.controller.text}',
          ),
        )
      else
        const SizedBox.shrink(),
      IconButton(
        tooltip: '清空',
        icon: const Icon(Icons.clear, size: 22),
        onPressed: ctrl.onClear,
      ),
      IconButton(
        tooltip: '搜索',
        onPressed: ctrl.submit,
        icon: const Icon(Icons.search, size: 22),
      ),
      const SizedBox(width: 10),
    ],
    title: TextField(
      autofocus: true,
      focusNode: ctrl.searchFocusNode,
      controller: ctrl.controller,
      textInputAction: TextInputAction.search,
      onChanged: ctrl.onChange,
      decoration: InputDecoration(
        visualDensity: .standard,
        hintText: ctrl.hintText ?? '搜索',
        border: InputBorder.none,
      ),
      onSubmitted: (value) => ctrl.submit(),
    ),
  );

  Widget _buildSearchSuggest(SSearchController ctrl) {
    final list = ctrl.searchSuggestList;
    return list.isNotEmpty &&
            list.first.term != null &&
            ctrl.controller.text != ''
        ? SliverList.list(
            children: list
                .map(
                  (item) => InkWell(
                    borderRadius: const .all(.circular(4)),
                    onTap: () => ctrl.onClickKeyword(item.term!),
                    child: Padding(
                      padding: const .only(left: 20, top: 9, bottom: 9),
                      child: Text.rich(
                        TextSpan(
                          children: Em.regTitle(item.textRich)
                              .map(
                                (e) => TextSpan(
                                  text: e.text,
                                  style: e.isEm
                                      ? TextStyle(
                                          fontWeight: .bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        )
                                      : null,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        : const SliverToBoxAdapter();
  }

  Widget _buildHotSearch(
    SSearchController ctrl, {
    bool isTrending = true,
  }) {
    final text = Text(
      isTrending ? '大家都在搜' : '搜索发现',
      strutStyle: const StrutStyle(leading: 0, height: 1),
      style: theme.textTheme.titleMedium!.copyWith(
        height: 1,
        fontWeight: .bold,
      ),
    );
    final outline = theme.colorScheme.outline;
    final secondary = theme.colorScheme.secondary;
    final style = TextStyle(
      height: 1,
      fontSize: 13,
      color: outline,
    );
    return SliverPadding(
      padding: .fromLTRB(
        10,
        !isTrending && (isPortrait || ctrl.enableTrending) ? 4 : 25,
        4,
        25,
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: const .fromLTRB(6, 0, 6, 6),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  isTrending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            text,
                            const SizedBox(width: 14),
                            TextButton(
                              style: const ButtonStyle(
                                visualDensity: .compact,
                                tapTargetSize: .shrinkWrap,
                                padding: WidgetStatePropertyAll(
                                  .symmetric(horizontal: 10),
                                ),
                              ),
                              onPressed: () =>
                                  AppNavigator.toNamed('/searchTrending'),
                              child: Row(
                                children: [
                                  Text(
                                    '完整榜单',
                                    strutStyle: const StrutStyle(
                                      leading: 0,
                                      height: 1,
                                    ),
                                    style: style,
                                  ),
                                  Icon(
                                    size: 18,
                                    Icons.keyboard_arrow_right,
                                    color: outline,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : text,
                  TextButton.icon(
                    style: const ButtonStyle(
                      visualDensity: .compact,
                      tapTargetSize: .shrinkWrap,
                      padding: WidgetStatePropertyAll(
                        .symmetric(horizontal: 10),
                      ),
                    ),
                    onPressed: isTrending
                        ? ctrl.queryTrendingList
                        : ctrl.queryRecommendList,
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 18,
                      color: secondary,
                    ),
                    label: Text(
                      '刷新',
                      strutStyle: const StrutStyle(leading: 0, height: 1),
                      style: TextStyle(height: 1, color: secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildHotKey(
            ctrl,
            isTrending ? ctrl.trendingState : ctrl.recommendData,
            isTrending,
          ),
        ],
      ),
    );
  }

  late final mainAxisExtent =
      16 + MediaQuery.textScalerOf(context).scale(14);

  Widget _buildHistory(SSearchController ctrl) {
    final list = ctrl.historyList;
    if (list.isEmpty) {
      return const SliverToBoxAdapter();
    }
    final secondary = theme.colorScheme.secondary;
    return SliverPadding(
      padding: .fromLTRB(
        10,
        !isPortrait
            ? 25
            : ctrl.enableTrending
                ? 0
                : 6,
        6,
        25,
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: const .fromLTRB(6, 0, 6, 6),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    '搜索历史',
                    strutStyle: const StrutStyle(leading: 0, height: 1),
                    style: theme.textTheme.titleMedium!.copyWith(
                      height: 1,
                      fontWeight: .bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _recordBtn(ctrl),
                  _exportBtn(ctrl),
                  const Spacer(),
                  TextButton.icon(
                    style: const ButtonStyle(
                      visualDensity: .compact,
                      tapTargetSize: .shrinkWrap,
                      padding: WidgetStatePropertyAll(
                        .symmetric(horizontal: 10),
                      ),
                    ),
                    onPressed: ctrl.onClearHistory,
                    icon: Icon(
                      Icons.clear_all_outlined,
                      size: 18,
                      color: secondary,
                    ),
                    label: Text(
                      '清空',
                      style: TextStyle(height: 1, color: secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFixedWrap(
            mainAxisExtent: mainAxisExtent,
            spacing: 8,
            runSpacing: 8,
            delegate: SliverChildBuilderDelegate(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              childCount: list.length,
              (context, index) => SearchText(
                text: list[index],
                onTap: ctrl.onClickKeyword,
                onLongPress: ctrl.onLongSelect,
                fontSize: 14,
                height: 1,
                padding: const .fromLTRB(11, 8, 11, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordBtn(SSearchController ctrl) {
    final enable = ctrl.recordSearchHistory;
    return IconButton(
      iconSize: 22,
      tooltip: enable ? '记录搜索' : '无痕搜索',
      icon: DisabledIcon(
        disable: !enable,
        child: Icon(
          Icons.history,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      style: const ButtonStyle(
        visualDensity: .comfortable,
        tapTargetSize: .shrinkWrap,
        padding: WidgetStatePropertyAll(.zero),
      ),
      onPressed: () {
        ctrl.recordSearchHistory = !enable;
        GStorage.setting.put(
          SettingBoxKey.recordSearchHistory,
          !enable,
        );
      },
    );
  }

  Widget _exportBtn(SSearchController ctrl) => IconButton(
    iconSize: 22,
    tooltip: '导入/导出历史记录',
    icon: Icon(
      Icons.import_export_outlined,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
    ),
    style: const ButtonStyle(
      visualDensity: .comfortable,
      tapTargetSize: .shrinkWrap,
      padding: WidgetStatePropertyAll(.zero),
    ),
    onPressed: () => showImportExportDialog<List>(
      context,
      title: '历史记录',
      localFileName: () => 'search',
      onExport: () => jsonEncode(ctrl.historyList),
      onImport: (json) {
        final list = List<String>.from(json);
        ctrl.importHistory(list);
      },
    ),
  );

  Widget _buildHotKey(
    SSearchController ctrl,
    LoadingState<CoreSearchRcmdData> loadingState,
    bool isTrending,
  ) {
    return switch (loadingState) {
      Success(:final response) when (response.list?.isNotEmpty ?? false) =>
        SliverHotKeyword(
          hotSearchList: response.list!,
          onClick: ctrl.onClickKeyword,
        ),
      Error(:final errMsg) => HttpError(
        safeArea: false,
        errMsg: errMsg,
        onReload: isTrending
            ? ctrl.queryTrendingList
            : ctrl.queryRecommendList,
      ),
      _ => const SliverToBoxAdapter(),
    };
  }
}
