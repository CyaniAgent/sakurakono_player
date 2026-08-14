/// Generic app-level update information (adapter-agnostic).
///
/// Produced by [AppRepository.checkUpdate] — every adapter maps its own
/// update mechanism (or absence of one) into this shape.
class CoreUpdateInfo {
  const CoreUpdateInfo({
    this.hasUpdate = false,
    this.latestVersion,
    this.downloadUrl,
    this.releaseNotes,
    this.publishedAt,
  });

  /// Whether a newer version is available.
  final bool hasUpdate;

  /// The newest version tag, e.g. `v1.2.3`.
  final String? latestVersion;

  /// Direct download URL for the newest release, when known.
  final String? downloadUrl;

  /// Human-readable release notes for the newest release.
  final String? releaseNotes;

  /// ISO-8601 publish time of the newest release.
  final String? publishedAt;
}
