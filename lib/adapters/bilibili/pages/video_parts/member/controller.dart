import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/core/container/app_container.dart';

class HorizontalMemberPageController
    extends CommonListControllerRiverpod<CoreSpaceArchiveData, CoreSpaceArchiveItem> {
  void attachRef(Ref ref) {}
  HorizontalMemberPageController({this.mid, required this.currAid}) {
    getUserInfo();
    queryData();
  }

  dynamic mid;

  LoadingState<CoreMemberInfoModel> _userState = LoadingState<CoreMemberInfoModel>.loading();
  LoadingState<CoreMemberInfoModel> get userState => _userState;
  set userState(LoadingState<CoreMemberInfoModel> value) {
    _userState = value;
    notifyListeners();
  }

  final Map userStat = {};


  Future<void> getUserInfo() async {
    final res = await (appRead(memberRepositoryProvider)).memberInfo(mid: mid);
    userState = switch (res) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    if (res.isSuccess) {
      getMemberStat();
      getMemberView();
    }
  }

  Future<void> getMemberStat() async {
    final res = await (appRead(memberRepositoryProvider)).memberStat(mid: mid);
    if (res case Success(:final response)) {
      userStat.addAll(response);
      notifyListeners();
    }
  }

  Future<void> getMemberView() async {
    if (!Accounts.main.isLogin) {
      return;
    }
    final res = await (appRead(memberRepositoryProvider)).memberView(mid: mid);
    if (res case Success(:final response)) {
      userStat.addAll(response);
      notifyListeners();
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    CoreSpaceArchiveData data = response.response;
    count = data.count;
    if (isRefresh) {
      if (isLoadPrevious) {
        hasPrev = data.hasPrev ?? false;
      } else {
        hasNext = data.hasNext ?? false;
      }
    }
    if (isLoadPrevious) {
      if (loadingState case Success(:final response)) {
        (data.item ??= <CoreSpaceArchiveItem>[]).addAll(response!);
      }
    } else if (!isRefresh) {
      if (loadingState case Success(:final response)) {
        (data.item ??= <CoreSpaceArchiveItem>[]).insertAll(0, response!);
      }
    }
    firstAid = data.item?.firstOrNull?.param;
    lastAid = data.item?.lastOrNull?.param;
    loadingState = Success(data.item);
    isLoadPrevious = false;
    page++;
    return true;
  }

  String? currAid;
  String? firstAid;
  String? lastAid;
  CoreArchiveOrderTypeApp order = .pubdate;
  int? count;
  bool isLoadPrevious = false;
  bool hasPrev = true;
  bool hasNext = true;

  @override
  Future<LoadingState<CoreSpaceArchiveData>> customGetData() async {
      final result = await (appRead(memberRepositoryProvider)).spaceArchive(
        type: .video,
        mid: mid,
        aid: page == 1
            ? currAid
            : isLoadPrevious
            ? firstAid
            : lastAid,
        order: order,
        sort: page != 1 && isLoadPrevious ? .asc : null,
        pn: null,
        next: null,
        seasonId: null,
        seriesId: null,
        includeCursor: page == 1 ? true : null,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onRefresh() {
    if (!hasPrev) {
      return Future.syncValue(null);
    }
    isLoadPrevious = true;
    return queryData();
  }

  @override
  Future<void> onReload() {
    firstAid = null;
    lastAid = null;
    hasNext = true;
    hasPrev = true;
    isEnd = false;
    page = 1;
    scrollController.jumpToTop();
    return super.onReload();
  }

  void queryBySort() {
    if (isLoading) return;
    order = order == .pubdate ? .click : .pubdate;
    onReload();
  }
}


