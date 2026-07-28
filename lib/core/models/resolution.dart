/// Display resolution enumeration from 144p to 4K.
enum CoreResolution {
  p144(0, '144p'),
  p240(1, '240p'),
  p360(2, '360p'),
  p480(3, '480p'),
  p720(4, '720p'),
  p1080(5, '1080p'),
  p1440(6, '1440p'),
  p2160(7, '4K');

  final int value;
  final String label;
  const CoreResolution(this.value, this.label);
}
