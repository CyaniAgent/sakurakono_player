import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/models/common/account_type.dart';
import 'package:skf/pages/mine/controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account.dart';
import 'package:skf/adapters/bilibili/utils/login_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

abstract final class Accounts {
  static late final Box account;
  static final List<Account> accountMode = List.filled(
    AccountType.values.length,
    AnonymousAccount(),
  );
  static bool get mainEqVideo => main == video;
  static Account get main => accountMode[AccountType.main.index];
  static Account get video => accountMode[AccountType.video.index];
  static Account get heartbeat => accountMode[AccountType.heartbeat.index];
  static Account get history {
    final heartbeat = Accounts.heartbeat;
    if (heartbeat is AnonymousAccount) {
      return Accounts.main;
    }
    return heartbeat;
  }
  // static set main(Account account) => set(AccountType.main, account);

  static Future<void> init() async {
    if (Hive.isBoxOpen('account')) {
      account = Hive.box('account');
    } else {
      account = await Hive.openBox(
        'account',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 2;
        },
      );
    }
  }

  static Future<void> refresh() {
    for (final a in account.values) {
      for (final t in a.type) {
        accountMode[t.index] = a;
      }
    }
    return Future.wait(
      (accountMode.toSet()..removeWhere((i) => i.activated)).map(
        Request.buvidActive,
      ),
    );
  }

  static Future<void> clear() async {
    if (kDebugMode) {
      // TODO(mcp-debug): 临时调试日志，定位账号丢失后移除
      debugPrint('MCP-DEBUG Accounts.clear ${StackTrace.current}');
    }
    await account.clear();
    for (int i = 0; i < AccountType.values.length; i++) {
      accountMode[i] = AnonymousAccount();
    }
    await AnonymousAccount().delete();
    Request.buvidActive(AnonymousAccount());
  }

  static Future<void> deleteAll(Set<Account> accounts) async {
    if (kDebugMode) {
      // TODO(mcp-debug): 临时调试日志，定位账号丢失后移除
      debugPrint(
        // ignore: lines_longer_than_80_chars
        'MCP-DEBUG Accounts.deleteAll mids=${accounts.map((a) => a is LoginAccount ? a.mid : -1).toList()} ${StackTrace.current}',
      );
    }
    final isLoginMain = Accounts.main.isLogin;
    for (int i = 0; i < AccountType.values.length; i++) {
      if (accounts.contains(accountMode[i])) {
        accountMode[i] = AnonymousAccount();
      }
    }
    await Future.wait(accounts.map((i) => i.delete()));
    if (isLoginMain && !Accounts.main.isLogin) {
      await LoginUtils.onLogoutMain();
    }
  }

  static Future<void> set(AccountType key, Account account) async {
    final oldAccount = accountMode[key.index]..type.remove(key);
    accountMode[key.index] = account..type.add(key);
    await Future.wait([?account.onChange(), ?oldAccount.onChange()]);
    if (!account.activated) await Request.buvidActive(account);
    switch (key) {
      case AccountType.main:
        await (account.isLogin
            ? LoginUtils.onLoginMain()
            : LoginUtils.onLogoutMain());
        break;
      case AccountType.heartbeat:
        MineController.anonymity.value = !account.isLogin;
        break;
      default:
        break;
    }
  }

  @pragma("vm:prefer-inline")
  static Account get(AccountType key) {
    return accountMode[key.index];
  }
}
