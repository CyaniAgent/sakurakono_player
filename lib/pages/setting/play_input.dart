/// 播放链接分类器：设置页「播放链接」入口的纯判定函数。
///
/// 必须保持纯函数：无 I/O、无 GetX、无 PiliScheme 调用
/// （routePushFromUrl 是 async 且 b23.tv 需网络 302，绝不能进纯函数）。
enum PlayInputKind { biliUrl, ottoVid, unknown }

/// 对播放输入进行分类（trim 后判定，大小写不敏感）：
///
/// - [PlayInputKind.biliUrl]：B站 URL/ID 形态——含 `bilibili.com` 或
///   `b23.tv`，或 `bilibili://` 前缀，或裸 `BV1xxxxxxxxx` / 裸 `av\d+`。
/// - [PlayInputKind.ottoVid]：`^\d+$` 全数字（OttoHub 视频 ID）。
/// - [PlayInputKind.unknown]：其他（含空串/纯空白）。
///
/// 已知行为：ADAPTER=bilibili 下贴纯数字会走 ottoVid 分支 → B站侧
/// toVideoPage 加载失败 → 错误提示（可接受，B站用户本就该贴 B站链接）。
PlayInputKind classifyPlayInput(String input) {
  final value = input.trim();
  if (value.isEmpty) return PlayInputKind.unknown;

  final lower = value.toLowerCase();
  if (lower.contains('bilibili.com') ||
      lower.contains('b23.tv') ||
      lower.startsWith('bilibili://')) {
    return PlayInputKind.biliUrl;
  }
  if (RegExp(r'^bv1[0-9a-zA-Z]{9}$', caseSensitive: false).hasMatch(lower)) {
    return PlayInputKind.biliUrl;
  }
  if (RegExp(r'^av\d+$', caseSensitive: false).hasMatch(lower)) {
    return PlayInputKind.biliUrl;
  }
  if (RegExp(r'^\d+$').hasMatch(lower)) {
    return PlayInputKind.ottoVid;
  }
  return PlayInputKind.unknown;
}
