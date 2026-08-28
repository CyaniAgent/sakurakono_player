import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/account/account_mixin.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:skf/pages/mine/theme_type.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class MineController extends CommonDataControllerRiverpod<CoreFavFolderData, CoreFavFolderData>
    with AccountMixin {
  int? favFolderCount;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.

  // 用户信息 头像、昵称、lv
  CoreUserInfoData _userInfo = CoreUserInfoData();
  CoreUserInfoData get userInfo => _userInfo;
  set userInfo(CoreUserInfoData value) {
    _userInfo = value;
    notifyListeners();
  }

  // 用户状态 动态、关注、粉丝
  CoreUserStat _userStat = const CoreUserStat();
  CoreUserStat get userStat => _userStat;
  set userStat(CoreUserStat value) {
    _userStat = value;
    notifyListeners();
  }

  ThemeType _themeType = ThemeType.values[Pref.themeType];
  ThemeType get themeType => _themeType;
  set themeType(ThemeType value) {
    _themeType = value;
    notifyListeners();
  }

  ThemeType get nextThemeType =>
      ThemeType.values[(_themeType.index + 1) % ThemeType.values.length];

  static final ValueNotifier<bool> anonymity = ValueNotifier(MineActions.of().isAnonymity);


  /// 菜单项（由适配器经 [MineActions.menuItems] 注入）。
  late final List<MineMenuItem> list = MineActions.of().menuItems;

  MineController() {
    initAccountListener();
    CoreUserInfoData? userInfoCache = Pref.userInfoCache;
    if (userInfoCache != null) {
      _userInfo = userInfoCache;
      queryData();
      queryUserInfo();
    }
  }

  bool get isLogin {
    if (!accountService.isLogin) {
      // SmartDialog.showToast('账号未登录');
      return false;
    }
    return true;
  }

  /// 点击菜单项：需登录的菜单项在未登录时忽略。
  void onMenuItemTap(MineMenuItem item) {
    if (item.loginRequired && !isLogin) return;
    item.onTap();
  }

  Future<void> queryUserInfo() async {
    final res = await (appRead(userRepositoryProvider)).userInfo();
    if (res case Success(:final response)) {
      if (response.isLogin == true) {
        userInfo = response;
        if (response != Pref.userInfoCache) {
          GStorage.userInfo.put('userInfoCache', response);
        }
        appRead(accountProvider.notifier)
          ..updateFace(response.face!)
          ..updateLogin(true);
      } else {
        _onLogoutMain();
        return;
      }
    } else {
      final errMsg = res.toString();
      SmartDialog.showToast(errMsg);
      if (errMsg == '账号未登录') {
        _onLogoutMain();
        return;
      }
    }
    queryUserStatOwner();
  }

  void _onLogoutMain() => MineActions.of().logout();

  Future<void> queryUserStatOwner() async {
    final res = await (appRead(userRepositoryProvider)).userStatOwner();
    if (res case Success(:final response)) {
      userStat = response;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreFavFolderData> response) {
    favFolderCount = response.response.count;
    loadingState = response;
    return true;
  }

  @override
  Future<LoadingState<CoreFavFolderData>> customGetData() async {
    final result = await (appRead(favRepositoryProvider)).userfavFolder(
      pn: 1,
      ps: 20,
      mid: accountService.userId,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  static void onChangeAnonymity() {
    if (!MineActions.of().canToggleAnonymity) {
      SmartDialog.showToast('请先登录');
      return;
    }
    final newVal = !anonymity.value;
    anonymity.value = newVal;
    if (newVal) {
      SmartDialog.dismiss();
      SmartDialog.show<bool>(
        clickMaskDismiss: false,
        usePenetrate: true,
        displayTime: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
        builder: (context) {
          final theme = Theme.of(context);
          final style = TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
          );
          return ColoredBox(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(MdiIcons.incognito, size: 20),
                      const SizedBox(width: 10),
                      Text('已进入无痕模式', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '搜索不携带身份信息\n'
                    '不产生查询或播放记录\n'
                    '点赞等其它操作不受影响\n'
                    '播放进度信息跟随视频取流\n'
                    '(前往隐私设置了解详情)',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          SmartDialog.dismiss(result: true);
                          SmartDialog.showToast('已设为永久无痕模式');
                        },
                        child: Text('保存为永久', style: style),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          SmartDialog.dismiss();
                          SmartDialog.showToast('已设为临时无痕模式');
                        },
                        child: Text('仅本次（默认）', style: style),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ).then((res) {
        if (res == false) {
          return;
        }
        MineActions.of().setAnonymity(true, permanent: res == true);
      });
    } else {
      MineActions.of().setAnonymity(false);
      SmartDialog.dismiss(result: false);
      SmartDialog.show(
        clickMaskDismiss: false,
        usePenetrate: true,
        displayTime: const Duration(seconds: 1),
        alignment: Alignment.bottomCenter,
        builder: (context) {
          final theme = Theme.of(context);
          return ColoredBox(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 15,
              ),
              child: Row(
                children: [
                  const Icon(MdiIcons.incognitoOff, size: 20),
                  const SizedBox(width: 10),
                  Text('已退出无痕模式', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void onChangeTheme() {
    final newVal = nextThemeType;
    themeType = newVal;
    GStorage.setting.put(SettingBoxKey.themeMode, newVal.index);
    Get.changeThemeMode(ThemeUtils.themeMode = newVal.toThemeMode);
  }

  void push(String name) {
    late final mid = userInfo.mid;
    if (isLogin && mid != null) {
      MineActions.of().openUserPage(name, mid);
    }
  }

  void onLogin([bool longPress = false]) {
    if (!accountService.isLogin || longPress) {
      MineActions.of().openLoginPage();
    } else {
      MineActions.of().openMemberPage(userInfo.mid);
    }
  }

  @override
  Future<void> onRefresh({bool isManual = true}) {
    if (!accountService.isLogin) {
      return Future.syncValue(null);
    }
    queryUserInfo();
    return super.onRefresh().whenComplete(() {
      if (isManual) {
        scrollController.jumpToTop();
      }
    });
  }

  @override
  void onChangeAccount(bool isLogin) {
    if (isLogin) {
      onRefresh();
    } else {
      userInfo = CoreUserInfoData();
      userStat = const CoreUserStat();
      loadingState = LoadingState.loading();
    }
  }

  @override
  void dispose() {
    disposeAccountListener();
    super.dispose();
  }
}
