import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:skf/core/plugin/data_source.dart';
import 'package:skf/core/plugin/plugin.dart';
import 'package:skf/core/plugin/plugin_registry.dart';

/// A plugin that provides local video files as data sources.
///
/// Uses [FilePicker] to let the user select a local video file from the
/// device filesystem. Supported formats: mp4, mkv, avi, mov, flv, wmv, webm.
///
/// [provideDataSource] returns `null` because file picking is inherently async;
/// use [pickFile] to show the native picker, or [fromPath] for programmatic
/// usage where the path is already known.
class LocalFilePlugin implements Plugin {
  @override
  String get name => 'local_file';

  @override
  Future<void> onRegister(PluginRegistry registry) async {
    // Plugin is self-contained; no cross-plugin setup needed.
  }

  @override
  DataSource? provideDataSource(String sourceId) {
    // FilePicker.pickFiles() is async, but provideDataSource is sync.
    // The caller should use pickFile() at the UI layer and then call
    // fromPath() with the result. This method returns null to indicate
    // that the actual picking must happen externally.
    if (sourceId != 'local_file') return null;
    return null;
  }

  /// Opens the native file picker and returns a [DataSource] for the
  /// selected video file, or `null` if the user cancels.
  Future<DataSource?> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['mp4', 'mkv', 'avi', 'mov', 'flv', 'wmv', 'webm'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return null;

    return DataSource(
      id: 'local_file:${file.name}',
      uri: Uri.file(path),
      title: file.name,
      metadata: <String, dynamic>{
        'size': file.size,
        'extension': file.extension,
      },
    );
  }

  /// Creates a [DataSource] from a direct file path without showing a picker.
  ///
  /// Useful when the UI layer has already obtained a file path through other
  /// means (e.g., drag-and-drop, recent files list, command-line argument).
  DataSource fromPath(String filePath) {
    final file = File(filePath);
    final name = file.uri.pathSegments.last;
    return DataSource(
      id: 'local_file:$name',
      uri: file.uri,
      title: name,
      metadata: <String, dynamic>{
        'size': file.lengthSync(),
        'extension': filePath.split('.').last,
      },
    );
  }
}
