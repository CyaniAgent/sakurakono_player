import 'dart:async';
import 'package:get/get.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/plugin/local_file_plugin.dart';
import 'package:skf/core/plugin/plugin_registry.dart';
import 'package:skf/core/player/media_source.dart';
import 'package:skf/core/player/player_controller.dart';
import 'package:skf/core/player/player_factory.dart';
import 'package:skf/core/player/playback_reporter.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/controller.dart'
    show PlPlayerController;
import 'package:skf/adapters/bilibili/plugin/pl_player/models/data_source.dart'
    show NetworkSource;
import 'package:skf/adapters/bilibili/plugin/pl_player/models/play_status.dart'
    show PlayerStatus;

PlPlayerController _controller({bool isLive = false}) =>
    PlPlayerController.getInstance(isLive: isLive);

class BiliPlayerFactory implements PlayerFactory {
  @override
  VideoPlayerController create() => _PlControllerAdapter();

  /// Opens a file picker via [LocalFilePlugin] and plays the selected file.
  /// Returns the controller once playback starts, or `null` if the user cancels.
  Future<VideoPlayerController?> openLocalFile() async {
    final registry = Get.find<PluginRegistry>();
    final plugin = registry.resolve<LocalFilePlugin>();
    if (plugin == null) return null;

    final dataSource = await plugin.pickFile();
    if (dataSource == null) return null;

    final mediaSource = dataSource.toMediaSource();
    final controller = create();
    await controller.open(mediaSource);
    return controller;
  }

  /// Opens a local file at [filePath] directly without showing a picker.
  /// Useful for drag-and-drop, recent files, or command-line arguments.
  Future<VideoPlayerController?> openLocalPath(String filePath) async {
    final registry = Get.find<PluginRegistry>();
    final plugin = registry.resolve<LocalFilePlugin>();
    if (plugin == null) return null;

    final dataSource = plugin.fromPath(filePath);
    final mediaSource = dataSource.toMediaSource();
    final controller = create();
    await controller.open(mediaSource);
    return controller;
  }
}

class _PlControllerAdapter implements VideoPlayerController {
  final _errorController = StreamController<PlayerError>.broadcast();

  @override
  PlaybackReporter? reporter;

  CoreMediaId? _currentId;
  StreamSubscription? _positionSub;
  StreamSubscription? _statusSub;

  @override
  Future<void> open(MediaSource source, {CoreMediaId? id, Duration? seekTo}) async {
    final isLive = source.extras['isLive'] == 'true';
    final ctr = _controller(isLive: isLive);

    await _positionSub?.cancel();
    await _statusSub?.cancel();

    await ctr.setDataSource(
      NetworkSource(videoSource: source.uri, audioSource: source.audioUri),
      seekTo: seekTo,
      autoplay: true,
    );

    _currentId = id;

    _positionSub = ctr.position.stream.listen((ms) {
      if (_currentId != null) {
        final position = Duration(milliseconds: ms);
        final duration = Duration(seconds: ctr.duration.value);
        reporter?.onProgress(_currentId!, position, duration);
      }
    });

    _statusSub = ctr.playerStatus.stream.listen((status) {
      if (status == PlayerStatus.completed && _currentId != null) {
        reporter?.onComplete(_currentId!);
      }
    });
  }

  @override
  Future<void> play() => _controller().play();

  @override
  Future<void> pause() => _controller().pause();

  @override
  Future<void> seek(Duration position) => _controller().seekTo(position);

  @override
  Future<void> setVolume(double volume) =>
      _controller().setVolume(volume, showIndicator: false);

  @override
  Future<void> setSpeed(double speed) =>
      _controller().setPlaybackSpeed(speed);

  @override
  void dispose() {
    _positionSub?.cancel();
    _statusSub?.cancel();
    _errorController.close();
  }

  @override
  Stream<Duration> onPositionChanged() =>
      _controller().position.stream.map((ms) => Duration(milliseconds: ms));

  @override
  Stream<Duration> onDurationChanged() =>
      _controller().duration.stream.map((sec) => Duration(seconds: sec));

  @override
  Stream<bool> onPlayingChanged() =>
      _controller().playerStatus.stream.map((s) => s == PlayerStatus.playing);

  @override
  Stream<bool> onBufferingChanged() => _controller().isBuffering.stream;

  @override
  Stream<PlayerError> onError() => _errorController.stream;

  @override
  double get volume => _controller().volume.value;

  @override
  double get speed => _controller().playbackSpeed;

  @override
  bool get isPlaying =>
      _controller().playerStatus.value == PlayerStatus.playing;
}
