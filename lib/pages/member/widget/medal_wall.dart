import 'package:skf/common/assets.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/pendant_avatar.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/pages/member/widget/medal_widget.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/num_ext.dart';
import 'package:flutter/material.dart';

class MedalWall extends StatelessWidget {
  const MedalWall({super.key, required this.response});

  final CoreMedalWallData response;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return AlertDialog(
      clipBehavior: .hardEdge,
      title: const Text('粉丝勋章墙'),
      contentPadding: const .symmetric(vertical: 16),
      constraints: const BoxConstraints.tightFor(width: 380),
      content: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: NetworkImgLayer(
                src: response.icon,
                width: 50,
                height: 50,
                type: .avatar,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const .only(top: 5),
              child: Center(child: Text(response.name!)),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const .only(top: 5, bottom: 8),
                child: Text.rich(
                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  TextSpan(
                    children: [
                      const TextSpan(text: '共拥有 '),
                      TextSpan(
                        text: response.count.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' 枚粉丝勋章'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: response.list!.length,
            itemBuilder: (context, index) {
              final item = response.list![index];
              final uinfoMedal = item.uinfoMedal!;
              final isLiving = item.liveStatus == 1;
              return ListTile(
                onTap: () {
                  if (isLiving) {
                    MemberHost.of().pushFromUri(item.link!);
                  } else {
                    AppNavigator.toNamed(
                      '/member?mid=${uinfoMedal.ruid}',
                      preventDuplicates: false,
                    );
                  }
                },
                visualDensity: .comfortable,
                leading: PendantAvatar(
                  item.targetIcon,
                  size: 38,
                  officialType: switch (item.official) {
                    1 => 0,
                    2 => 1,
                    _ => null,
                  },
                  onTap: isLiving
                      ? () => AppNavigator.toNamed(
                          '/member?mid=${uinfoMedal.ruid}',
                          preventDuplicates: false,
                        )
                      : null,
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.targetName!,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: const TextStyle(height: 1, fontSize: 14),
                      ),
                    ),
                    if (isLiving)
                      Padding(
                        padding: const .only(left: 4),
                        child: Image.asset(
                          Assets.livingChart,
                          height: 16,
                          cacheHeight: 16.cacheSize(context),
                          color: colorScheme.primary,
                        ),
                      ),
                    Padding(
                      padding: const .only(left: 8),
                      child: MedalWidget.fromMedal(
                        medalName: uinfoMedal.name!,
                        level: uinfoMedal.level!,
                        colorStart: uinfoMedal.v2MedalColorStart!,
                        colorText: uinfoMedal.v2MedalColorText!,
                      ),
                    ),
                  ],
                ),
                trailing: item.medalInfo!.wearingStatus == 1
                    ? Container(
                        padding: const .symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: const .all(.circular(3)),
                          color: colorScheme.brightness == Brightness.light
                              ? const Color(0xFFFF6699)
                              : const Color(0xFF8F0030),
                        ),
                        child: const Text(
                          '佩戴中',
                          style: TextStyle(
                            height: 1,
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          strutStyle: StrutStyle(
                            height: 1,
                            leading: 0,
                            fontSize: 10,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
