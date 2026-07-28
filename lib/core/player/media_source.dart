/// A media source with URI, optional audio, and headers.
/// Subtypes: [NetworkMediaSource], [FileMediaSource].
sealed class MediaSource {
  String get uri;
  String? get audioUri;
  Map<String, String> get headers;
  Map<String, String> get extras;
}

/// A network-hosted media source with optional audio URI and custom headers.
class NetworkMediaSource extends MediaSource {
  @override
  final String uri;
  @override
  final String? audioUri;
  @override
  final Map<String, String> headers;
  @override
  final Map<String, String> extras;

  NetworkMediaSource({
    required this.uri,
    this.audioUri,
    this.headers = const {},
    this.extras = const {},
  });
}

/// A local file media source.
class FileMediaSource extends MediaSource {
  @override
  final String uri;
  @override
  final Map<String, String> headers;
  @override
  final Map<String, String> extras;

  FileMediaSource({
    required this.uri,
    this.headers = const {},
    this.extras = const {},
  });

  @override
  String? get audioUri => null;
}
