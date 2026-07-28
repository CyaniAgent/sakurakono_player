/// Video quality enum with internal value codes. Maps to [CoreResolution].
enum CoreVideoQuality {
  unknown(-1, 'Unknown'),
  p360(16, '360P 流畅'),
  p480(32, '480P 清晰'),
  p720(64, '720P 高清'),
  p1080(80, '1080P 高清'),
  p1080Plus(112, '1080P 高码率'),
  p1080Hdr(126, '1080P HDR'),
  p1440(74, '1440P 2K'),
  p2160(75, '2160P 4K'),
  p4320(125, '4320P 8K');

  final int value;
  final String label;
  const CoreVideoQuality(this.value, this.label);

  static CoreVideoQuality fromValue(int value) {
    return CoreVideoQuality.values.firstWhere(
      (v) => v.value == value,
      orElse: () => CoreVideoQuality.unknown,
    );
  }
}
