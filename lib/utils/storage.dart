import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/set_int_adapter.dart';
import 'package:skf/utils/utils.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as path;

abstract final class GStorage {
  static late Box<dynamic> userInfo;
  static late Box _accountBox;
  static late Box<dynamic> historyWord;
  static late Box<dynamic> localCache;
  static late Box<dynamic> setting;
  static late Box<dynamic> video;
  static late Box<int> watchProgress;
  static late Box<Uint8List>? reply;

  static Future<void> init() async {
    Hive.init(path.join(appSupportDirPath, 'hive'));
    regAdapter();

    await Future.wait([
      // 登录用户信息
      Hive.openBox<dynamic>(
        'userInfo',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 2;
        },
      ).then((res) => userInfo = res),
      // 本地缓存
      Hive.openBox(
        'localCache',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 4;
        },
      ).then((res) => localCache = res),
      // 设置
      Hive.openBox('setting').then((res) => setting = res),
      // 搜索历史
      Hive.openBox(
        'historyWord',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 10;
        },
      ).then((res) => historyWord = res),
      // 视频设置
      Hive.openBox('video').then((res) => video = res),
      Hive.openBox(
        'account',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 2;
        },
      ).then((res) => _accountBox = res),
      Hive.openBox<int>(
        'watchProgress',
        keyComparator: _intStrDescKeyComparator,
        compactionStrategy: (entries, deletedEntries) {
          return deletedEntries > 4;
        },
      ).then((res) => watchProgress = res),
    ]);

    if (setting.get('saveReply', defaultValue: true) as bool) {
      reply = await Hive.openBox<Uint8List>(
        'reply',
        keyComparator: _intStrDescKeyComparator,
        compactionStrategy: (entries, deletedEntries) {
          return deletedEntries > 10;
        },
      );
    } else {
      reply = null;
    }
  }

  /// 防御性恢复：init() 失败时把受损 Hive 数据目录隔离（重命名备份）后重试。
  /// 诊断信息同时输出到 stderr 并追加写入 storage_init_error.log（release 下可见）。
  /// 返回 true 表示恢复成功（应用可继续正常启动），false 表示重试仍失败。
  static Future<bool> recoverInit(Object error) async {
    final hiveDir = path.join(appSupportDirPath, 'hive');
    final backupDir =
        '$hiveDir.bak-${DateTime.now().millisecondsSinceEpoch}';
    void report(String message) {
      stderr.writeln('[SKF] $message');
      try {
        File(path.join(appSupportDirPath, 'storage_init_error.log'))
            .writeAsStringSync(
          '${DateTime.now()}: $message\n',
          mode: FileMode.append,
        );
      } catch (_) {
        // 日志写入失败不影响恢复流程
      }
    }

    report('GStorage init failed: $error');
    try {
      await Hive.close(); // 释放已打开 box 的文件锁，否则 Windows 上无法重命名目录
      final dir = Directory(hiveDir);
      if (dir.existsSync()) {
        await dir.rename(backupDir);
        report('isolated corrupted Hive data to: $backupDir');
      }
    } catch (isolateError) {
      report('failed to isolate Hive data: $isolateError');
    }
    try {
      await init();
      report('GStorage recovered after isolating corrupted Hive data');
      return true;
    } catch (retryError) {
      report('GStorage init failed again after isolation: $retryError');
      return false;
    }
  }

  static String exportAllSettings() {
    return Utils.jsonEncoder.convert({
      setting.name: setting.toMap(),
      video.name: video.toMap(),
    });
  }

  static Future<void> importAllSettings(String data) =>
      importAllJsonSettings(jsonDecode(data));

  static Future<List<void>> importAllJsonSettings(
    Map<String, dynamic> map,
  ) {
    return Future.wait([
      setting.clear().then((_) => setting.putAll(map[setting.name])),
      video.clear().then((_) => video.putAll(map[video.name])),
    ]);
  }

  static void regAdapter() {
    // 幂等：数据隔离后重试 init() 时 adapter 已注册，跳过避免重复注册异常
    if (!Hive.isAdapterRegistered(SetIntAdapter().typeId)) {
      Hive.registerAdapter(SetIntAdapter());
    }
  }

  static Future<List<void>> compact() {
    return Future.wait([
      userInfo.compact(),
      historyWord.compact(),
      localCache.compact(),
      setting.compact(),
      video.compact(),
      _accountBox.compact(),
      watchProgress.compact(),
      ?reply?.compact(),
    ]);
  }

  static Future<List<void>> close() {
    return Future.wait([
      userInfo.close(),
      historyWord.close(),
      localCache.close(),
      setting.close(),
      video.close(),
      _accountBox.close(),
      watchProgress.close(),
      ?reply?.close(),
    ]);
  }

  static Future<List<void>> clear() {
    return Future.wait([
      userInfo.clear(),
      historyWord.clear(),
      localCache.clear(),
      setting.clear(),
      video.clear(),
      _accountBox.clear(),
      watchProgress.clear(),
      ?reply?.clear(),
    ]);
  }

  static int _intStrDescKeyComparator(dynamic k1, dynamic k2) {
    if (k1 is int) {
      if (k2 is int) {
        return k2.compareTo(k1);
      } else {
        return -1;
      }
    } else if (k2 is String) {
      final lenCompare = k2.length.compareTo((k1 as String).length);
      if (lenCompare == 0) {
        return k2.compareTo(k1);
      } else {
        return lenCompare;
      }
    } else {
      return 1;
    }
  }
}
