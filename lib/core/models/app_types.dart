import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_types.freezed.dart';

/// Generic app-level update information (adapter-agnostic).
///
/// Produced by [AppRepository.checkUpdate] — every adapter maps its own
/// update mechanism (or absence of one) into this shape.
@freezed
abstract class CoreUpdateInfo with _$CoreUpdateInfo {
  const factory CoreUpdateInfo({
    @Default(false) bool hasUpdate,
    String? latestVersion,
    String? downloadUrl,
    String? releaseNotes,
    String? publishedAt,
  }) = _CoreUpdateInfo;
}
