import 'package:flutter/foundation.dart' show debugPrint;
import 'package:fixnum/fixnum.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [SpaceRepository] for OttoHub.
///
/// **searchArchive** — implemented via `_client.video.search(uid:)` which
/// filters results by uploader UID.
/// **opusSpaceFlow** — stubbed (OttoHub has no opus/notes concept).
class OttoSpaceRepository implements SpaceRepository {
  final OttohubClient _client;

  OttoSpaceRepository(this._client);

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<CoreSearchArchiveReply>> searchArchive({
    required String keyword,
    required Int64 mid,
    required int pn,
    required Int64 ps,
  }) async {
    try {
      final result = await _client.video.search(
        searchTerm: keyword,
        offset: (pn - 1) * ps.toInt(),
        num: ps.toInt(),
        uid: mid.toInt(),
      );
      return _ok(CoreSearchArchiveReply(
        total: result.totalCount ?? result.videoList.length,
        archives: result.videoList.map((v) => <String, dynamic>{
          'title': v.title,
          'author': v.username,
          'bvid': v.vid.toString(),
          'aid': v.vid,
          'pic': v.coverUrl,
          'play': v.viewCount,
          'pubdate': v.time,
          'description': v.intro ?? '',
        }).toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoSpaceRepository.searchArchive ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreOpusSpaceFlowResp>> opusSpaceFlow({
    required int hostMid,
    String? next,
    required String filterType,
  }) async =>
      _err(const ApiException('not_implemented'));
}