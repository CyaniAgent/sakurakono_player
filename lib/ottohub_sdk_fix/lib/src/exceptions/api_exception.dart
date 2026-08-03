/// API 错误异常。
///
/// 当服务器返回 `{"status": "error", "message": "error_code"}` 时抛出。
/// [errorCode] 为服务器返回的错误码字符串，例如 `error_token`、`missing_argument`。
///
/// 增强后可选携带 HTTP 状态码、原始响应数据和内部异常（如 DioException）。
///
/// 常见错误码及各接口的可能错误值，见各 API 方法文档及 `docs/*.md`。
class ApiException implements Exception {
  /// 服务器返回的错误码，如 `error_token`、`system_error`、`too_many_requests`。
  final String errorCode;

  /// HTTP 状态码（当由 HTTP 错误触发时）。
  final int? httpStatus;

  /// 服务器返回的原始响应数据。
  final Map<String, dynamic>? responseData;

  /// 内部异常（如包装的 DioException）。
  final Exception? innerException;

  /// 创建一个 API 异常。
  ///
  /// [errorCode]: 服务器返回的错误码。
  /// [httpStatus]: 可选的 HTTP 状态码。
  /// [responseData]: 可选的原始响应数据。
  /// [innerException]: 可选的内部异常。
  const ApiException(
    this.errorCode, {
    this.httpStatus,
    this.responseData,
    this.innerException,
  });

  @override
  String toString() {
    final buf = StringBuffer(errorCode);
    if (httpStatus != null) buf.write(' (HTTP $httpStatus)');
    if (innerException != null) buf.write(' [$innerException]');
    return buf.toString();
  }
}
