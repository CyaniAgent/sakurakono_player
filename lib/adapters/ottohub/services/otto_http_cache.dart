// 通用网络响应缓存(适配层专用,Hive 持久化)。
//
// 用途:
// 1. timeout/网络失败时回退到上次成功的数据(有缓存就能看,没有给提示);
// 2. TTL 内直接复用上次数据,减少重复请求。
//
// 存储:key → {ts: 写入毫秒, payload: 原始 JSON}。与图片磁盘缓存
// (CachedNetworkImage,按 URL)互补,不替代。

import 'dart:convert';

import 'package:hive_ce/hive.dart';

class OttoHttpCache {
  OttoHttpCache._(this._box);

  static const _boxName = 'otto_http_cache';
  static const Duration _defaultTtl = Duration(minutes: 30);

  final Box<String>? _box;

  /// Hive 不可用时的进程内回退(单测/初始化前),内容不持久化。
  static final Map<String, String> _memFallback = {};

  static OttoHttpCache? _instance;

  /// 惰性初始化;Hive 打开失败(如单测未初始化)退化为内存缓存,
  /// 保证调用方零异常。
  static Future<OttoHttpCache> getInstance() async {
    final cached = _instance;
    if (cached != null) return cached;
    Box<String>? box;
    try {
      box = await Hive.openBox<String>(_boxName);
    } catch (_) {
      box = null;
    }
    return _instance ??= OttoHttpCache._(box);
  }

  String? _read(String key) {
    final box = _box;
    if (box == null) return _memFallback[key];
    try {
      return box.get(key);
    } catch (_) {
      return _memFallback[key];
    }
  }

  void _write(String key, String value) {
    _memFallback[key] = value;
    try {
      _box?.put(key, value);
    } catch (_) {}
  }

  void _delete(String key) {
    _memFallback.remove(key);
    try {
      _box?.delete(key);
    } catch (_) {}
  }

  /// 读取未过期的缓存 JSON;无缓存/已过期返回 null。
  Map<String, dynamic>? getJson(String key, {Duration ttl = _defaultTtl}) {
    final raw = _read(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = map['ts'] as int? ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - ts > ttl.inMilliseconds) {
        _delete(key);
        return null;
      }
      return map['payload'] as Map<String, dynamic>;
    } catch (_) {
      _delete(key);
      return null;
    }
  }

  /// 写缓存(异常静默:缓存失败不影响主流程)。
  void putJson(String key, Map<String, dynamic> payload) {
    _write(
      key,
      jsonEncode({
        'ts': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      }),
    );
  }

  /// 组合 key:路径 + 已排序的稳定查询参数。
  static String keyFor(String path, Map<String, dynamic> query) {
    final params = query.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${e.value}')
        .toList()
      ..sort();
    return '$path?${params.join('&')}';
  }
}
