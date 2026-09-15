import 'package:flutter/material.dart';
import 'package:skf/build_config.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/app_meta.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

/// 关于页(框架级):展示应用元信息,可选触发更新检查
/// (更新检查经 core `AppRepository.checkUpdate`,由适配器实现)。
class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _checking = false;

  Future<void> _checkUpdate() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final res = await (appRead(appRepositoryProvider))
          .checkUpdate(currentVersion: BuildConfig.versionName);
      if (!mounted) return;
      final info = switch (res) {
        Success(:final response) => response,
        _ => null,
      };
      final message = info == null
          ? '检查更新失败'
          : info.hasUpdate
              ? '发现新版本 ${info.latestVersion ?? ''}'
              : '当前已是最新版本';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final body = ListView(
      padding: const .symmetric(horizontal: 24, vertical: 32),
      children: [
        Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo/logo_2.png',
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppMeta.appName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'v${BuildConfig.versionName} (${BuildConfig.versionCode})',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.system_update),
                title: const Text('检查更新'),
                trailing: _checking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _checkUpdate,
              ),
              if (AppMeta.sourceCodeUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('源代码'),
                  subtitle: Text(
                    AppMeta.sourceCodeUrl,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('构建信息'),
                subtitle: Text(
                  'commit ${BuildConfig.commitHash}\n'
                  'built ${DateTime.fromMillisecondsSinceEpoch(BuildConfig.buildTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('关于')),
        body: body,
      );
    }
    return body;
  }
}
