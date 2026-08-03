import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/player/playback_reporter.dart';

class OttoReporter implements PlaybackReporter {
  @override
  Future<void> onProgress(
    CoreMediaId id,
    Duration position,
    Duration duration,
  ) async {
    // TODO(otto): implement playback reporting
  }

  @override
  Future<void> onComplete(CoreMediaId id) async {
    // TODO(otto): implement playback reporting
  }

  @override
  Future<void> onSeek(
    CoreMediaId id,
    Duration from,
    Duration to,
  ) async {
    // TODO(otto): implement playback reporting
  }

  @override
  Future<void> onPause(CoreMediaId id, Duration position) async {
    // TODO(otto): implement playback reporting
  }

  @override
  Future<void> onPlay(CoreMediaId id, Duration position) async {
    // TODO(otto): implement playback reporting
  }
}
