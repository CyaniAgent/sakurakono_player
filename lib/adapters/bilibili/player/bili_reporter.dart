import 'package:skf/adapters/bilibili/http/video.dart';
import 'package:skf/adapters/bilibili/player/media_ids.dart';
import 'package:skf/core/models/media_id.dart' show CoreMediaId;
import 'package:skf/core/player/playback_reporter.dart';

class BiliReporter implements PlaybackReporter {
  @override
  Future<void> onProgress(CoreMediaId id, Duration position, Duration duration) async {
    final cid = _extractCoreCid(id);
    if (cid == null) return;
    await VideoHttp.heartBeat(
      aid: _extractCoreAid(id),
      bvid: _extractCoreBvid(id),
      cid: cid,
      epid: _extractCoreEpid(id),
      progress: position.inSeconds,
      videoType: _resolveVideoType(id),
    );
  }

  @override
  Future<void> onComplete(CoreMediaId id) async {
    final cid = _extractCoreCid(id);
    if (cid == null) return;
    await VideoHttp.heartBeat(
      aid: _extractCoreAid(id),
      bvid: _extractCoreBvid(id),
      cid: cid,
      epid: _extractCoreEpid(id),
      progress: -1,
      videoType: _resolveVideoType(id),
    );
  }

  @override
  Future<void> onSeek(CoreMediaId id, Duration from, Duration to) async {}

  @override
  Future<void> onPause(CoreMediaId id, Duration position) async {}

  @override
  Future<void> onPlay(CoreMediaId id, Duration position) async {}

  String? _extractCoreAid(CoreMediaId id) => id is CoreAid ? id.id : null;
  String? _extractCoreBvid(CoreMediaId id) => id is CoreBvid ? id.id : null;
  String? _extractCoreCid(CoreMediaId id) => id is CoreCid ? id.id : null;
  String? _extractCoreEpid(CoreMediaId id) => id is CoreEpid ? id.id : null;

  dynamic _resolveVideoType(CoreMediaId id) {
    if (id is CoreEpid) return 1;
    if (id is CoreSid) return 2;
    return 0;
  }
}
