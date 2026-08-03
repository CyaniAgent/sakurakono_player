/// Compile-time feature flags controlled via --dart-define.
///
/// In the default build (no --dart-define), all features are enabled
/// (full Bilibili experience).
///
/// For OttoHub builds, disable unsupported features:
///   --dart-define=FEATURE_SEARCH=false
///   --dart-define=FEATURE_LIVE=false
///   ...
abstract final class AppFeatures {
  static const bool hasSearch = bool.fromEnvironment('FEATURE_SEARCH', defaultValue: true);
  static const bool hasLive = bool.fromEnvironment('FEATURE_LIVE', defaultValue: true);
  static const bool hasMusic = bool.fromEnvironment('FEATURE_MUSIC', defaultValue: true);
  static const bool hasDanmakuFilter = bool.fromEnvironment('FEATURE_DM_FILTER', defaultValue: true);
  static const bool hasAudio = bool.fromEnvironment('FEATURE_AUDIO', defaultValue: true);
  static const bool hasMatch = bool.fromEnvironment('FEATURE_MATCH', defaultValue: true);
  static const bool hasSpace = bool.fromEnvironment('FEATURE_SPACE', defaultValue: true);
  static const bool hasDownload = bool.fromEnvironment('FEATURE_DOWNLOAD', defaultValue: true);
  static const bool hasPgc = bool.fromEnvironment('FEATURE_PGC', defaultValue: true);
  static const bool hasSponsorBlock = bool.fromEnvironment('FEATURE_SPONSOR', defaultValue: true);
  static const bool hasValidate = bool.fromEnvironment('FEATURE_VALIDATE', defaultValue: true);
}
