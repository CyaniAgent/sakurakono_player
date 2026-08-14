
/// Subtitle format enum — adapter-independent.
enum SubtitleFormat {
  json('JSON'),
  vtt('WEBVTT'),
  srt('SRT');

  final String label;
  const SubtitleFormat(this.label);
}