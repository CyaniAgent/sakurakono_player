/// Audio quality enum (64K / 320K / Hi-Res / Dolby Atmos).
enum CoreAudioQuality {
  unknown(-1, 'Unknown'),
  low(30250, '64K'),
  high(30280, '320K'),
  lossless(30272, 'Hi-Res'),
  atmos(30282, 'Dolby Atmos');

  final int value;
  final String label;
  const CoreAudioQuality(this.value, this.label);

  static CoreAudioQuality fromValue(int value) {
    return CoreAudioQuality.values.firstWhere(
      (v) => v.value == value,
      orElse: () => CoreAudioQuality.unknown,
    );
  }
}
