import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/string_ext.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:stream_transform/stream_transform.dart';

// 纯数字匹配（uid 判断）——原 IdUtils.digitOnlyRegExp 的等价纯函数
final _digitOnlyRegExp = RegExp(r'^\d+$');

mixin DebounceStreamMixin<T> {
  final Duration duration = const Duration(milliseconds: 200);
  StreamController<T>? ctr;
  StreamSubscription<T>? _sub;
  void onValueChanged(T value);

  void subInit() {
    _sub = (ctr = StreamController<T>()).stream
        .debounce(duration, trailing: true)
        .listen(onValueChanged);
  }

  void subDispose() {
    _sub?.cancel();
    ctr?.close();
    _sub = null;
    ctr = null;
  }
}

abstract class DebounceStreamState<T extends StatefulWidget, S> extends State<T>
    with DebounceStreamMixin<S> {
  @override
  void dispose() {
    subDispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subInit();
  }
}

// ---------------------------------------------------------------------------
// BaseSearchController — shared state (trending, history, prefs)
// ---------------------------------------------------------------------------

class BaseSearchController extends ChangeNotifier {
  BaseSearchController(this._ref);
  final Ref _ref;

  final historyList = List<String>.from(
    GStorage.historyWord.get('cacheList') ?? const <String>[],
  );

  late LoadingState<CoreSearchTrendingData> trendingState;

  bool _recordSearchHistory = Pref.recordSearchHistory;
  bool get recordSearchHistory => _recordSearchHistory;
  set recordSearchHistory(bool value) {
    _recordSearchHistory = value;
    notifyListeners();
  }

  final bool searchSuggestion = Pref.searchSuggestion;
  final bool enableTrending = Pref.enableTrending;
  final bool enableSearchRcmd = Pref.enableSearchRcmd;

  void init() {
    if (enableTrending) {
      trendingState = LoadingState<CoreSearchTrendingData>.loading();
      queryTrendingList();
    }
  }

  // 获取热搜关键词
  Future<void> queryTrendingList() async {
    final result =
        await _ref.read(searchRepositoryProvider).searchTrending(limit: 10);
    trendingState = switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// SSearchParams — route params for the per-page search controller
// ---------------------------------------------------------------------------

typedef SSearchParams = ({String tag, String? hintText, String? text});

// ---------------------------------------------------------------------------
// SSearchController — per-search-page controller (Riverpod ChangeNotifier)
// ---------------------------------------------------------------------------

class SSearchController extends ChangeNotifier
    with DebounceStreamMixin<String> {
  SSearchController(this._ref, this._params)
      : _baseCtr = _ref.read(baseSearchProvider) {
    hintText = _params.hintText;
    final text = _params.text;
    if (text != null) {
      _textEditingController.text = text;
    }

    if (_baseCtr.searchSuggestion) {
      subInit();
      _searchSuggestList = [];
    }

    if (_baseCtr.enableSearchRcmd) {
      _recommendData = LoadingState<CoreSearchRcmdData>.loading();
      queryRecommendList();
    }
  }

  final Ref _ref;
  final SSearchParams _params;

  final _searchFocusNode = FocusNode();
  final _textEditingController = TextEditingController();
  final BaseSearchController _baseCtr;

  String? hintText;

  int initIndex = 0;

  // uid
  bool showUidBtn = false;

  // history
  bool get recordSearchHistory => _baseCtr.recordSearchHistory;
  set recordSearchHistory(bool value) {
    _baseCtr.recordSearchHistory = value;
    notifyListeners();
  }

  List<String> get historyList => _baseCtr.historyList;

  // suggestion
  bool get searchSuggestion => _baseCtr.searchSuggestion;
  late List<CoreSearchSuggestItem> _searchSuggestList;
  List<CoreSearchSuggestItem> get searchSuggestList => _searchSuggestList;

  // trending
  bool get enableTrending => _baseCtr.enableTrending;
  LoadingState<CoreSearchTrendingData> get trendingState =>
      _baseCtr.trendingState;

  // rcmd
  bool get enableSearchRcmd => _baseCtr.enableSearchRcmd;
  late LoadingState<CoreSearchRcmdData> _recommendData;
  LoadingState<CoreSearchRcmdData> get recommendData => _recommendData;

  Future<void> Function() get queryTrendingList =>
      _baseCtr.queryTrendingList;

  FocusNode get searchFocusNode => _searchFocusNode;
  TextEditingController get controller => _textEditingController;

  void validateUid() {
    showUidBtn = _digitOnlyRegExp.hasMatch(_textEditingController.text);
    notifyListeners();
  }

  void onChange(String value) {
    validateUid();
    if (searchSuggestion) {
      if (value.isEmpty) {
        _searchSuggestList = [];
        notifyListeners();
      } else {
        ctr!.add(value);
      }
    }
  }

  void onClear() {
    if (_textEditingController.value.text != '') {
      _textEditingController.clear();
      if (searchSuggestion) {
        _searchSuggestList = [];
        notifyListeners();
      }
      _searchFocusNode.requestFocus();
      showUidBtn = false;
      notifyListeners();
    } else {
      AppNavigator.back();
    }
  }

  // 搜索
  Future<void> submit() async {
    if (_textEditingController.text.isEmpty) {
      if (hintText.isNullOrEmpty) {
        return;
      }
      _textEditingController.text = hintText!;
      validateUid();
    }

    if (recordSearchHistory) {
      historyList
        ..remove(_textEditingController.text)
        ..insert(0, _textEditingController.text);
      GStorage.historyWord.put('cacheList', historyList);
    }

    sSearchByTagRegistry[_params.tag] = this;
    _searchFocusNode.unfocus();
    await AppNavigator.toNamed(
      '/searchResult',
      parameters: {
        'tag': _params.tag,
        'keyword': _textEditingController.text,
      },
      arguments: {
        'initIndex': initIndex,
        'fromSearch': true,
      },
    );
    _searchFocusNode.requestFocus();
  }

  Future<void> queryRecommendList() async {
    final result =
        await _ref.read(searchRepositoryProvider).searchRecommend();
    _recommendData = switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    notifyListeners();
  }

  void onClickKeyword(String keyword) {
    _textEditingController.text = keyword;
    validateUid();

    if (searchSuggestion) {
      _searchSuggestList = [];
      notifyListeners();
    }
    submit();
  }

  @override
  Future<void> onValueChanged(String value) async {
    final res =
        await _ref.read(searchRepositoryProvider).searchSuggest(term: value);
    if (res case Success(:final response)) {
      if (response.tag?.isNotEmpty == true) {
        _searchSuggestList = response.tag!;
        notifyListeners();
      }
    }
  }

  void onLongSelect(String word) {
    historyList.remove(word);
    GStorage.historyWord.put('cacheList', historyList);
    notifyListeners();
  }

  void onClearHistory() {
    showConfirmDialog(
      context: AppNavigator.context!,
      title: const Text('确定清空搜索历史？'),
      onConfirm: () {
        historyList.clear();
        GStorage.historyWord.delete('cacheList');
        notifyListeners();
      },
    );
  }

  /// Import a list of history words (replaces current history).
  void importHistory(List<String> list) {
    historyList
      ..clear()
      ..addAll(list);
    GStorage.historyWord.put('cacheList', list);
    notifyListeners();
  }

  @override
  void dispose() {
    subDispose();
    _searchFocusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Singleton provider for the shared base search state.
final baseSearchProvider = ChangeNotifierProvider<BaseSearchController>((ref) {
  return BaseSearchController(ref)..init();
});

/// Per-page search controller, keyed by [SSearchParams.tag].
final sSearchProvider =
    ChangeNotifierProvider.autoDispose.family<SSearchController, SSearchParams>(
  (ref, params) {
    final controller = SSearchController(ref, params);
    return controller;
  },
);

/// SSearchController 注册表 — 搜索页导航到结果页前按 [SSearchParams.tag] 登记，
/// 供 search_result 页按 tag 读取同一实例（替代 GetX tag 注册；
/// family 按完整 params 键控，结果页只有 tag 无法重建）。
final Map<String, SSearchController> sSearchByTagRegistry = {};

final sSearchByTagProvider = Provider.family<SSearchController, String>(
  (ref, tag) => sSearchByTagRegistry[tag] ??
      (throw StateError('SSearchController not registered for tag: $tag')),
);
