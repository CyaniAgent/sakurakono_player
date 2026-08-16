/// Generic classification of a "playback input" string (设置页「播放链接」).
///
/// Adapters classify the trimmed input via [AppAdapter.classifyPlayInput]
/// so platform-specific recognition (URL hosts, video-ID shapes) stays in
/// the adapter and the shared pages only dispatch on the generic kinds.
enum PlayInputKind {
  /// A URL/ID the adapter can route via [AppAdapter.openUrl]
  /// (e.g. Bilibili: bilibili.com / b23.tv / bilibili:// / BV / av).
  videoUrl,

  /// A pure-numeric video ID (`^\d+$`), opened via `SettingHost.openVideoById`.
  numericId,

  /// Anything the active adapter does not recognize.
  unknown,
}
