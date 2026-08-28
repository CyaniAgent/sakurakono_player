import 'package:skf/adapters/bilibili/http/api.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/repository_providers.dart';

import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';

class MemberFavoriteCtr
    extends CommonControllerRiverpod<List<CoreSpaceFavData>?, List<CoreSpaceFavData>?> {
  MemberFavoriteCtr({
    required this.mid,
  }) {
    queryData();
  }

  final int mid;

  late int favPage = 2;
  bool _favExpand = true;
  bool favEnd = true;
  CoreSpaceFavData favState = CoreSpaceFavData();

  late int subPage = 2;
  bool _subExpand = true;
  bool subEnd = true;
  CoreSpaceFavData subState = CoreSpaceFavData();

  LoadingState<List<CoreSpaceFavData>?> _loadingState =
      LoadingState<List<CoreSpaceFavData>?>.loading();
  @override
  LoadingState<List<CoreSpaceFavData>?> get loadingState => _loadingState;
  set loadingState(LoadingState<List<CoreSpaceFavData>?> value) {
    _loadingState = value;
    notifyListeners();
  }

  bool isExpand(bool isFav) {
    return isFav ? _favExpand : _subExpand;
  }

  void setExpand(bool isFav) {
    if (isFav) {
      flag = _favExpand;
      _favExpand = !_favExpand;
    } else {
      _subExpand = !_subExpand;
    }
  }

  bool flag = false;


  @override
  Future<void> onRefresh() {
    favPage = 2;
    subPage = 2;
    return super.onRefresh();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading) return;
    isLoading = true;
    final LoadingState<List<CoreSpaceFavData>?> res = await customGetData();
    if (res is Success<List<CoreSpaceFavData>?>) {
      if (!customHandleResponse(isRefresh, res)) {
        loadingState = res;
      }
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState = res as Error;
      }
    }
    isLoading = false;
  }

  @override
  Future<void> onReload() {
    loadingState = LoadingState<List<CoreSpaceFavData>?>.loading();
    return super.onReload();
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<List<CoreSpaceFavData>?> response,
  ) {
    try {
      List<CoreSpaceFavData> res = response.response!;
      favState = res.first;
      subState = res[1];

      favEnd =
          (res.first.mediaListResponse?.count ?? -1) <=
          (res.first.mediaListResponse?.list?.length ?? -1);
      subEnd =
          (res[1].mediaListResponse?.count ?? -1) <=
          (res[1].mediaListResponse?.list?.length ?? -1);
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
    }
    loadingState = response;
    return true;
  }

  Future<void> userFavFolder() async {
    try {
      final res = await Request().get(
        Api.userFavFolder,
        queryParameters: {
          'pn': favPage,
          'ps': 20,
          'up_mid': mid,
        },
      );
      if (res.data['code'] == 0) {
        favPage++;
        final data = res.data['data'];
        if (data != null) {
          favEnd = data['has_more'] == false;
          final list = (data['list'] as List<dynamic>?)
              ?.map((item) => CoreSpaceFavItemModel.fromJson(item))
              .toList();
          if (list != null && list.isNotEmpty) {
            favState.mediaListResponse!.list!.addAll(list);
          } else {
            favEnd = true;
          }
        } else {
          favEnd = true;
        }
      } else {
        SmartDialog.showToast(res.data['message']);
      }
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  Future<void> userSubFolder() async {
    try {
      final res = await Request().get(
        Api.userSubFolder,
        queryParameters: {
          'up_mid': mid,
          'ps': 20,
          'pn': subPage,
          'platform': 'web',
        },
      );
      if (res.data['code'] == 0) {
        subPage++;
        final data = res.data['data'];
        if (data != null) {
          subEnd = data['has_more'] == false;
          final list = (data['list'] as List<dynamic>?)
              ?.map((item) => CoreSpaceFavItemModel.fromJson(item))
              .toList();
          if (list != null && list.isNotEmpty) {
            subState.mediaListResponse!.list!.addAll(list);
          } else {
            subEnd = true;
          }
        } else {
          subEnd = true;
        }
      } else {
        SmartDialog.showToast(res.data['message']);
      }
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  @override
  Future<LoadingState<List<CoreSpaceFavData>?>> customGetData() async {
    final result = await (appRead(favRepositoryProvider)).spaceFav(mid: mid);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
