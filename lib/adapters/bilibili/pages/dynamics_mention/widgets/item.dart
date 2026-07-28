import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/models/ui/image_type.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:flutter/material.dart';

class DynMentionItem extends StatefulWidget {
  const DynMentionItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onCheck,
  });

  final CoreMentionItem item;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheck;

  @override
  State<DynMentionItem> createState() => _DynMentionItemState();
}

class _DynMentionItemState extends State<DynMentionItem> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        dense: true,
        onTap: widget.onTap,
        visualDensity: .standard,
        leading: NetworkImgLayer(
          src: widget.item.face,
          width: 42,
          height: 42,
          type: CoreImageType.avatar,
        ),
        title: Text(
          widget.item.name!,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          '${NumUtils.numFormat(widget.item.fans)}粉丝',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        trailing: Checkbox(
          tristate: false,
          value: _checked,
          onChanged: (value) {
            setState(() => _checked = value!);
            widget.onCheck(value);
          },
        ),
      ),
    );
  }
}
