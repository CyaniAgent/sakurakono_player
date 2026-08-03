import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:skf/core/player/media_source.dart';
import 'package:skf/core/player/player_controller.dart';
import 'package:skf/core/player/player_factory.dart';
import 'package:skf/core/player/playback_reporter.dart';
import 'package:skf/core/models/media_id.dart';

class OttoPlayerFactory implements PlayerFactory {
  @override
  VideoPlayerController create() => OttoVideoPlayerController();
}

class OttoVideoPlayerController implements VideoPlayerController {
  Player? _player;
  Future<void>? _initFuture;

  @override
  double get volume => _player?.state.volume ?? 0.0;

  @override
  double get speed => _player?.state.rate ?? 1.0;

  @override
  bool get isPlaying => _player?.state.playing ?? false;

  @override
  PlaybackReporter? reporter;

  Future<Player> _ensurePlayer() async {
    if (_player != null) return _player!;
    _initFuture ??= _initPlayer();
    await _initFuture;
    return _player!;
  }

  Future<void> _initPlayer() async {
    _player = await Player.create();
  }

  @override
  Future<void> open(MediaSource source, {CoreMediaId? id, Duration? seekTo}) async {
    final player = await _ensurePlayer();
    await player.open(Media(source.uri.toString()));
    if (seekTo != null) await player.seek(seekTo);
  }

  @override
  Future<void> play() async {
    final player = await _ensurePlayer();
    await player.play();
  }

  @override
  Future<void> pause() async {
    final player = await _ensurePlayer();
    await player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    final player = await _ensurePlayer();
    await player.seek(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    final player = await _ensurePlayer();
    await player.setVolume(volume);
  }

  @override
  Future<void> setSpeed(double speed) async {
    final player = await _ensurePlayer();
    await player.setRate(speed);
  }

  @override
  void dispose() {
    _player?.dispose();
  }

  @override
  Stream<Duration> onPositionChanged() =>
      _player?.stream.position ?? const Stream.empty();

  @override
  Stream<Duration> onDurationChanged() =>
      _player?.stream.duration ?? const Stream.empty();

  @override
  Stream<bool> onPlayingChanged() =>
      _player?.stream.playing ?? const Stream.empty();

  @override
  Stream<bool> onBufferingChanged() =>
      _player?.stream.buffering ?? const Stream.empty();

  @override
  Stream<PlayerError> onError() =>
      (_player?.stream.error ?? const Stream<String>.empty()).map(
        (e) => PlayerError(message: e, isFatal: true),
      );
}
