import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 通用内嵌浏览器页(框架级):按 URL 打开,不注入任何平台凭据。
class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  String _currentTitle = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTitle.isNotEmpty ? _currentTitle : (widget.title ?? widget.url),
          maxLines: 1,
          overflow: .ellipsis,
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          userAgent:
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
          transparentBackground: true,
        ),
        onTitleChanged: (_, title) {
          if (mounted) setState(() => _currentTitle = title ?? '');
        },
      ),
    );
  }
}
