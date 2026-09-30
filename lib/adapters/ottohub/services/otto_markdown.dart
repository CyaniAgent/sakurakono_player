// 轻量 Markdown 处理(适配层专用)。
//
// OttoHub 博客/动态正文为 markdown(官网用 marked 渲染)。列表内仅需
// 可读纯文本:剥离图片与行内样式标记;完整渲染统一走
// `MarkdownText`(lib/common/widgets/markdown_text.dart)。

/// 移除图片标记并剥离行内样式,返回列表用纯文本。
String stripMarkdownToPlain(String source) {
  var text = source.replaceAllMapped(
    RegExp(r'!\[([^\]]*)\]\(([^)]*[^)\s])\s*\)'),
    (m) => '[图片]',
  );
  text = text.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\(([^)]*[^)\s])\s*\)'),
    (m) => m.group(1)!,
  );
  text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1)!);
  text = text.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*|__(.+?)__'),
    (m) => m.group(1) ?? m.group(2) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'(?<!\*)\*(?!\*)([^*]+)(?<!\*)\*(?!\*)'),
    (m) => m.group(1)!,
  );
  text = text.replaceAllMapped(RegExp(r'^#{1,6}\s+', multiLine: true), (m) => '');
  text = text.replaceAllMapped(RegExp(r'^>\s?', multiLine: true), (m) => '');
  text = text.replaceAllMapped(RegExp(r'^[-*]\s+', multiLine: true), (m) => '• ');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}
