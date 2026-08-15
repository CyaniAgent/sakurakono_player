import 'package:skf/pages/setting/models/model.dart';
import 'package:flutter/material.dart';

/// 通用设置项列表框架：渲染 [SettingsModel] 列表。
///
/// 由设置域宿主（B站: [BiliSettingHost]）以 `title + settings` 构造；
/// 本组件零适配器依赖。
class CommonSetting extends StatefulWidget {
  const CommonSetting({
    super.key,
    required this.title,
    required this.settings,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final String title;
  final List<SettingsModel> settings;

  @override
  State<CommonSetting> createState() => _CommonSettingState();
}

class _CommonSettingState extends State<CommonSetting> {
  late EdgeInsets padding;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    padding = MediaQuery.viewPaddingOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final showAppBar = widget.showAppBar;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: showAppBar ? AppBar(title: Text(widget.title)) : null,
      body: ListView.builder(
        key: ValueKey(widget.title),
        padding: EdgeInsets.only(
          left: showAppBar ? padding.left : 0,
          right: showAppBar ? padding.right : 0,
          bottom: padding.bottom + 100,
        ),
        itemCount: widget.settings.length,
        itemBuilder: (context, index) => widget.settings[index].widget,
      ),
    );
  }
}
