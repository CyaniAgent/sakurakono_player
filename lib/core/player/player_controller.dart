import 'package:skf/core/player/media_source.dart';
import 'package:skf/core/player/playback_reporter.dart';
import 'package:skf/core/models/media_id.dart';

/// Error information emitted by [VideoPlayerController.onError].
class PlayerError {
  final String message;
  final bool isFatal;
  final dynamic originalError;

  const PlayerError({
    required this.message,
    this.isFatal = false,
    this.originalError,
  });
}

/// Abstract video player controller. Implementations wrap platform players
/// (media_kit, exo, etc.) and expose a uniform control surface.
abstract class VideoPlayerController {
  Future<void> open(MediaSource source, {CoreMediaId? id, Duration? seekTo});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setSpeed(double speed);
  void dispose();

  Stream<Duration> onPositionChanged();
  Stream<Duration> onDurationChanged();
  Stream<bool> onPlayingChanged();
  Stream<bool> onBufferingChanged();
  Stream<PlayerError> onError();

  PlaybackReporter? reporter;
  double get volume;
  double get speed;
  bool get isPlaying;
}
