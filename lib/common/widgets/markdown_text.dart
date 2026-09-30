// 统一 Markdown 渲染组件(全应用唯一入口)。
//
// OttoHub 博客/动态正文为 markdown(官网用 marked 渲染)。实现链路:
// `markdown` 包转 HTML → `flutter_html` 渲染,图片走 CachedNetworkImage
// 磁盘缓存,点击进图片查看器。
//
// [MarkdownText.plain] 提供信息流列表用的精简形态:剥掉图片标记后的
// 纯文本(避免列表内重复渲染大图)。

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/utils.dart';

/// 把 markdown 转为 HTML(marked 兼容子集,含表格/代码块/删除线)。
String markdownToHtml(String source) =>
    md.markdownToHtml(source, inlineSyntaxes: [md.EmojiSyntax()]);

/// 统一 Markdown 渲染。
class MarkdownText extends StatelessWidget {
  const MarkdownText(
    this.markdown, {
    super.key,
    this.baseStyle,
    this.imgMaxWidth,
  });

  final String markdown;
  final TextStyle? baseStyle;

  /// 限制内容区最大宽度(桌面居中列等场景)。
  final double? imgMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: markdownToHtml(markdown),
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(baseStyle?.fontSize ?? 15),
          lineHeight: LineHeight(1.6),
          color: baseStyle?.color ?? Theme.of(context).colorScheme.onSurface,
        ),
        'img': Style(width: Width.auto()),
      },
      onLinkTap: (url, _, _) {
        if (url == null || url.isEmpty) return;
        DynamicsHostRouter.openLink(url);
      },
      extensions: const [],
    );
  }
}

/// 信息流列表用的精简文本:剥掉图片标记与行内样式,仅保留可读文本。
class MarkdownPlain extends StatelessWidget {
  const MarkdownPlain(
    this.markdown, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  final String markdown;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final plain = markdown
        .replaceAll(RegExp(r'!\[([^\]]*)\]\(([^)]*)\)'), '[图片]')
        .replaceAllMapped(RegExp(r'\[([^\]]+)\]\(([^)]*)\)'), (m) => m.group(1)!)
        .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1)!)
        .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!)
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    return Text(
      plain,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 动态正文的图片点击查看转发(供 flutter_html onImageTap 使用)。
class DynamicsHostRouter {
  static void openLink(String url) {
    final vid = RegExp(r'/v/(\d+)').firstMatch(url);
    final blog = RegExp(r'/b/(\d+)').firstMatch(url);
    if (vid != null) {
      final id = int.tryParse(vid.group(1)!);
      if (id != null) {
        AppNavigator.toNamed(
          '/videoV',
          preventDuplicates: false,
          arguments: <String, dynamic>{
            'aid': id,
            'bvid': '$id',
            'cid': id,
            'heroTag': Utils.makeHeroTag(id),
          },
        );
        return;
      }
    }
    if (blog != null) {
      AppNavigator.toNamed('/blogDetail?bid=${blog.group(1)}');
      return;
    }
    AppNavigator.toNamed('/webview', parameters: {'url': url});
  }
}
