import 'package:flutter/material.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTTOhub SDK Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final client = OttohubClient();
  String _status = '未登录';

  Future<void> _login() async {
    try {
      final resp = await client.auth.login('demo@ottohub.cn', 'demo123');
      client.token = resp.token;
      setState(() => _status = '已登录 (uid: ${resp.uid})');
    } on ApiException catch (e) {
      setState(() => _status = '登录失败: ${e.errorCode}');
    }
  }

  Future<void> _fetchVideos() async {
    try {
      final result = await client.video.getRandom(num: 5);
      final titles = result.videoList.map((v) => v.title).join('\n');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(titles.isEmpty ? '暂无视频' : titles)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请求失败: ${e.errorCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTTOhub SDK 示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('状态: $_status'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('登录'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchVideos,
              child: const Text('获取随机视频'),
            ),
          ],
        ),
      ),
    );
  }
}

