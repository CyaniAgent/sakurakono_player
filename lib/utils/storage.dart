import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/set_int_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  static Future<void> init() async {
    Hive.init(path.join(appSupportDirPath, 'hive'));
    regAdapter();

    // userInfo 独立打开：凭证(账密/token)落盘加密，含旧明文数据一次性迁移。
    userInfo = await _openUserInfoBox();
    // 历史故障备份含明文凭据副本：仅保留最近 2 份，失败不影响启动。
    unawaited(_cleanupHiveBackups());

    await Future.wait([
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
  }

  static bool _userInfoCompaction(int entries, int deletedEntries) =>
      deletedEntries > 2;

  /// 从系统安全存储读取 userInfo 加密密钥；不存在则生成并写回。
  /// 任何失败由调用方兜底（回退明文，不阻断启动）。
  static Future<List<int>> _loadCipherKey(FlutterSecureStorage secure) async {
    const keyName = 'skf_hive_userinfo_cipher';
    final stored = await secure.read(key: keyName);
    if (stored != null && stored.isNotEmpty) {
      final key = base64Decode(stored);
      if (key.length == 32) {
        return key;
      }
    }
    final key = Hive.generateSecureKey();
    await secure.write(key: keyName, value: base64Encode(key));
    return key;
  }

  static Future<Box<dynamic>> _openUserInfoPlain() {
    return Hive.openBox<dynamic>(
      'userInfo',
      compactionStrategy: _userInfoCompaction,
    );
  }

  /// userInfo Box：HiveAesCipher 加密（密钥在系统安全存储）。
  /// 旧明文 box 在首次运行时一次性迁移；任何一步失败都回退明文打开，
  /// 保持旧行为且不阻断启动（迁移标记不写，下次启动自动重试）。
  static Future<Box<dynamic>> _openUserInfoBox() async {
    const secure = FlutterSecureStorage();
    const flagKey = 'skf_userinfo_encrypted';
    bool wasEncrypted;
    List<int>? key;
    try {
      wasEncrypted = await secure.read(key: flagKey) == '1';
      key = await _loadCipherKey(secure);
    } catch (e) {
      stderr.writeln('[SKF] secure storage unavailable, userInfo falls back '
          'to plaintext: $e');
      return _openUserInfoPlain();
    }
    final cipher = HiveAesCipher(key);

    // 一次性迁移：存在旧明文 box 且从未启用加密。
    if (!wasEncrypted && await Hive.boxExists('userInfo')) {
      try {
        final legacy = await Hive.openBox<dynamic>('userInfo');
        final legacyData = legacy.toMap();
        await legacy.close();
        await legacy.deleteFromDisk();
        final box = await Hive.openBox<dynamic>(
          'userInfo',
          encryptionCipher: cipher,
          compactionStrategy: _userInfoCompaction,
        );
        if (legacyData.isNotEmpty) {
          await box.putAll(legacyData);
        }
        await secure.write(key: flagKey, value: '1');
        return box;
      } catch (e) {
        stderr.writeln('[SKF] userInfo encryption migration failed, '
            'falling back to plaintext: $e');
        try {
          await Hive.close();
        } catch (_) {}
        return _openUserInfoPlain();
      }
    }

    try {
      final box = await Hive.openBox<dynamic>(
        'userInfo',
        encryptionCipher: cipher,
        compactionStrategy: _userInfoCompaction,
      );
      if (!wasEncrypted) {
        await secure.write(key: flagKey, value: '1');
      }
      return box;
    } catch (e) {
      if (!wasEncrypted) {
        // 可能是历史明文残留：按明文打开（迁移标记未写，下次启动重试加密迁移）。
        stderr.writeln('[SKF] userInfo encrypted open failed, falling back '
            'to plaintext: $e');
        try {
          await Hive.close();
        } catch (_) {}
        return _openUserInfoPlain();
      }
      rethrow;
    }
  }

  /// 清理 recoverInit 隔离出来的历史备份目录（含明文凭据副本），保留最近 2 份。
  static Future<void> _cleanupHiveBackups() async {
    try {
      final hiveDir = Directory(path.join(appSupportDirPath, 'hive'));
      final parent = hiveDir.parent;
      if (!parent.existsSync()) {
        return;
      }
      final backups =
          parent.listSync().whereType<Directory>().where((d) {
            return path.basename(d.path).startsWith('hive.bak-');
          }).toList()
            ..sort((a, b) => b.path.compareTo(a.path));
      for (final dir in backups.skip(2)) {
        await dir.delete(recursive: true);
      }
    } catch (_) {
      // 清理失败不影响启动
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
