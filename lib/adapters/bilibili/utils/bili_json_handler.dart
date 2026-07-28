import 'package:skf/adapters/bilibili/services/logger.dart';
import 'package:skf/utils/json_file_handler.dart';

abstract final class BiliJsonFileHandler {
  static Future<JsonFileHandler?> init({
    bool enableDeviceParameters = true,
    bool enableApplicationParameters = true,
    bool enableStackTrace = true,
    bool enableCustomParameters = true,
    bool printLogs = false,
    bool handleWhenRejected = false,
  }) =>
      JsonFileHandler.init(
        getLogsPath: LoggerUtils.getLogsPath,
        logger: logger,
        enableDeviceParameters: enableDeviceParameters,
        enableApplicationParameters: enableApplicationParameters,
        enableStackTrace: enableStackTrace,
        enableCustomParameters: enableCustomParameters,
        printLogs: printLogs,
        handleWhenRejected: handleWhenRejected,
      );
}
