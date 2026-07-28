enum CoreSourceType { fileImage, networkImage, livePhoto }

class CoreSourceModel {
  final CoreSourceType sourceType;
  final String url;
  final String? liveUrl;
  final int? width;
  final int? height;
  final bool isLongPic;

  const CoreSourceModel({
    this.sourceType = CoreSourceType.networkImage,
    required this.url,
    this.liveUrl,
    this.width,
    this.height,
    this.isLongPic = false,
  });
}
