import 'dart:async';

/// Generic media playback service abstraction.
/// Implemented by lib/player/ (Wave 2); pages depend only on this interface.
abstract class CorePlayerService {
  Future<void> open(
    MediaDescriptor descriptor, {
    Duration? seekTo,
    bool autoplay = true,
  });
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setSpeed(double speed);
  Future<void> dispose();

  Stream<CorePlaybackEvent> get events;
}

/// Describes a media item to open through [CorePlayerService.open].
class MediaDescriptor {
  const MediaDescriptor({
    required this.uri,
    this.audioUri,
    this.title,
    this.posterUri,
    this.extras,
  });

  final String uri;
  final String? audioUri;
  final String? title;
  final String? posterUri;
  final Map<String, dynamic>? extras;
}

/// Kinds of playback events emitted by [CorePlayerService.events].
enum CorePlaybackEventType { position, duration, playing, buffering, completed, error }

/// A single playback event; [payload] carries the typed value when the
/// event kind has one (e.g. position/duration as [Duration]), [message]
/// carries a human-readable detail for [CorePlaybackEventType.error].
class CorePlaybackEvent {
  const CorePlaybackEvent(this.type, {this.payload, this.message});

  final CorePlaybackEventType type;
  final Object? payload;
  final String? message;
}
