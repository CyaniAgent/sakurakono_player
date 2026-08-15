import 'package:skf/common/style.dart';

/// 封面裁切比例：有真实宽高时按真实比例，否则回退默认 16:10。
///
/// B站 视频封面一般为 16:10；适配器若在 dimension 中提供了宽高
/// （如竖屏视频），则按真实比例裁切，避免封面变形。
/// 无 dimension 数据的模型（如收藏夹封面）始终返回 [Style.aspectRatio]。
double coverAspectRatio(num? width, num? height) {
  if (width != null && height != null && width > 0 && height > 0) {
    return width / height;
  }
  return Style.aspectRatio;
}
