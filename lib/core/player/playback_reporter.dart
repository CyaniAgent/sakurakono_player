import 'package:skf/core/models/media_id.dart';

/// Reports playback progress/events to the source service (e.g. heartbeat reporting).
abstract class PlaybackReporter {
  Future<void> onProgress(CoreMediaId id, Duration position, Duration duration);
  Future<void> onComplete(CoreMediaId id);
  Future<void> onSeek(CoreMediaId id, Duration from, Duration to);
  Future<void> onPause(CoreMediaId id, Duration position);
  Future<void> onPlay(CoreMediaId id, Duration position);
}
