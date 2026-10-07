import 'package:skf/core/models/follow_item.dart' show CoreFollowItemModel;
import 'package:skf/pages/fan/controller.dart';
import 'package:skf/pages/follow/follow_models.dart' show UserModel;
import 'package:skf/pages/follow_type/view.dart';
import 'package:skf/pages/follow_type/widgets/item.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/parse_int.dart';
import 'package:flutter/material.dart';

class FansPage extends StatefulWidget {
  const FansPage({
    super.key,
    this.showName = true,
    this.onSelect,
  });

  final bool showName;
  final ValueChanged<UserModel>? onSelect;

  @override
  State<FansPage> createState() => _FansPageState();

  static void toFansPage({dynamic mid, String? name}) {
    if (mid == null) {
      return;
    }
    AppNavigator.toNamed(
      '/fan',
      arguments: {
        'mid': safeToInt(mid),
        'name': name,
      },
    );
  }
}

class _FansPageState extends FollowTypePageState<FansPage> {
  @override
  late final FansController controller;
  late final flag = widget.onSelect == null && controller.isOwner;

  @override
  void initState() {
    super.initState();
    controller = FansController(widget.showName);
  }

  @override
  PreferredSizeWidget? get appBar => widget.showName
      ? AppBar(
          title: controller.isOwner
              ? const Text('我的粉丝')
              : ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final name = controller.name;
                  if (name != null) return Text('$name的粉丝');
                  return const SizedBox.shrink();
                },
              ),
        )
      : null;

  @override
  Widget buildItem(int index, CoreFollowItemModel item) {
    // OttoHub 服务端无「移除粉丝」API：按能力降级隐藏长按/右键入口。

    return FollowTypeItem(
      item: item,
      onTap: () {
        if (widget.onSelect != null) {
          widget.onSelect!(
            UserModel(
              mid: item.mid,
              name: item.uname!,
              avatar: item.face!,
              selected: true,
            ),
          );
          return;
        }
        AppNavigator.toNamed('/member?mid=${item.mid}');
      },
    );
  }
}
