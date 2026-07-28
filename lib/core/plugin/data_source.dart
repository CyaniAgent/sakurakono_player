import 'package:skf/core/player/media_source.dart';

/// Represents a data source provided by a plugin.
class DataSource {
  final String id;
  final Uri uri;
  final String title;
  final Map<String, dynamic>? metadata;

  const DataSource({
    required this.id,
    required this.uri,
    required this.title,
    this.metadata,
  });

  /// Converts this data source to a [FileMediaSource] for the player.
  /// The [extras] map is forwarded to [FileMediaSource] for player metadata.
  FileMediaSource toMediaSource({Map<String, String> extras = const {}}) {
    return FileMediaSource(
      uri: uri.toString(),
      extras: extras,
    );
  }
}
