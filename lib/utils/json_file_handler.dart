import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:logger/logger.dart';

class JsonFileHandler extends ReportHandler {
  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableStackTrace;
  final bool enableCustomParameters;
  final bool printLogs;
  final bool handleWhenRejected;
  final Logger? _logger;

  static Future<RandomAccessFile>? _future;

  JsonFileHandler._({
    this.enableDeviceParameters = true,
    this.enableApplicationParameters = true,
    this.enableStackTrace = true,
    this.enableCustomParameters = true,
    this.printLogs = false,
    this.handleWhenRejected = false,
    this._logger,
  });

  static Future<JsonFileHandler?> init({
    required Future<File> Function() getLogsPath,
    Logger? logger,
    bool enableDeviceParameters = true,
    bool enableApplicationParameters = true,
    bool enableStackTrace = true,
    bool enableCustomParameters = true,
    bool printLogs = false,
    bool handleWhenRejected = false,
  }) async {
    try {
      _future = getLogsPath()
          .then((file) => file.open(mode: FileMode.writeOnlyAppend))
          .then((raf) => raf.writeFrom(const []))
          .then(_flush);
      await _future;
      return JsonFileHandler._(
        enableDeviceParameters: enableDeviceParameters,
        enableApplicationParameters: enableApplicationParameters,
        enableStackTrace: enableStackTrace,
        enableCustomParameters: enableCustomParameters,
        printLogs: printLogs,
        handleWhenRejected: handleWhenRejected,
        logger: logger,
      );
    } catch (e, s) {
      logger?.e('Init log file', error: e, stackTrace: s);
      return null;
    }
  }

  static Future<RandomAccessFile> _flush(RandomAccessFile raf) => raf.flush();

  static Future<RandomAccessFile> add(
    Future<RandomAccessFile> Function(RandomAccessFile) onValue,
  ) {
    final future = _future;
    if (future == null) {
      return Future.error(StateError('JsonFileHandler not initialized'));
    }
    return _future = future.then(onValue).then(_flush);
  }

  @override
  Future<bool> handle(Report report) async {
    try {
      await _processReport(report);
      return true;
    } catch (exc, stackTrace) {
      _logger?.e(
        'Write Json Exception occurred',
        error: exc,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _processReport(Report report) {
    if (printLogs) {
      _logger?.d('Writing report to file');
    }
    final json = report.toJson(
      enableDeviceParameters: enableDeviceParameters,
      enableApplicationParameters: enableApplicationParameters,
      enableStackTrace: enableStackTrace,
      enableCustomParameters: enableCustomParameters,
    );
    return add((raf) => raf.writeString('${jsonEncode(json)}\n'));
  }
}
