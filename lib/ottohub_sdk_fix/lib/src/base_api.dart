import 'package:dio/dio.dart';
import 'exceptions/api_exception.dart';
import 'exceptions/api_error_codes.dart';

/// API 兼容模式配置值对象。
///
/// 将三个独立布尔参数封装为一个不可变对象，减少构造器参数膨胀。
/// 使用 [const BaseApiConfig()] 可在编译期构造，零运行时开销。
class BaseApiConfig {
  /// 将 HTTP 层面的 DioException 包装为 ApiException。
  ///
  /// 当 `true` 时，get / post / put / delete 方法会在 try-catch 中捕获
  /// DioException 并重新抛为带 HTTP 状态码和响应数据的 ApiException。
  final bool wrapHttpErrors;

  /// 宽松响应校验。
  ///
  /// 当 `true` 时：
  /// - 允许 API 返回非 Map 格式的 data（如数组、null）
  /// - 允许响应中没有 `status` 字段
  final bool relaxedResponse;

  /// 宽松类型转换。
  ///
  /// 当 `true` 时，`safeList` 和 `safeMap` 方法会静默过滤掉类型不匹配的
  /// 元素，而不会在反序列化时抛出异常。
  final bool relaxedTypes;

  const BaseApiConfig({
    this.wrapHttpErrors = false,
    this.relaxedResponse = false,
    this.relaxedTypes = false,
  });

  /// 严格模式（所有兼容标志关闭）。
  static const strict = BaseApiConfig();
}

/// 所有 API 模块的抽象基类。
///
/// 提供统一的 HTTP 方法封装（GET / POST / PUT / DELETE）和响应校验。
/// Token 自动注入规则：
/// - GET / DELETE → queryParameters
/// - POST / PUT → body data
/// - POST + [FormData] → 表单字段
abstract class BaseApi {
  BaseApi(
    this._dio,
    this._getToken, {
    this.config = const BaseApiConfig(),
  });

  final Dio _dio;
  final String? Function() _getToken;

  /// 兼容模式配置。
  final BaseApiConfig config;

  /// 发送 GET 请求。
  ///
  /// [path]: API 路径（不含 base URL）。
  /// [queryParameters]: URL 查询参数。token 会自动注入。
  /// **返回**: 解析后的 JSON Map。
  /// **抛出**: [ApiException] 或 [DioException]。
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = _getToken();
    if (token != null) {
      (queryParameters ??= {})['token'] = token;
    }
    final response = await _wrapHttpError(() => _dio.get(
          path,
          queryParameters: queryParameters,
        ));
    return _validate(response);
  }

  /// 发送 POST 请求。
  ///
  /// [path]: API 路径（不含 base URL）。
  /// [data]: JSON body（token 会自动注入）。
  /// [formData]: 表单数据（用于文件上传，token 会自动添加为字段）。
  /// **返回**: 解析后的 JSON Map。
  /// **抛出**: [ApiException] 或 [DioException]。
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
  }) async {
    final token = _getToken();
    if (formData != null) {
      if (token != null) {
        formData.fields.add(MapEntry('token', token));
      }
      final response =
          await _wrapHttpError(() => _dio.post(path, data: formData));
      return _validate(response);
    }
    if (token != null) {
      (data ??= {})['token'] = token;
    }
    final response = await _wrapHttpError(() => _dio.post(path, data: data));
    return _validate(response);
  }

  /// 发送 PUT 请求。
  ///
  /// [path]: API 路径（不含 base URL）。
  /// [data]: JSON body（token 会自动注入）。
  /// **返回**: 解析后的 JSON Map。
  /// **抛出**: [ApiException] 或 [DioException]。
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final token = _getToken();
    if (token != null) {
      (data ??= {})['token'] = token;
    }
    final response = await _wrapHttpError(() => _dio.put(path, data: data));
    return _validate(response);
  }

  /// 发送 DELETE 请求。
  ///
  /// [path]: API 路径（不含 base URL）。
  /// [queryParameters]: URL 查询参数。
  /// [data]: JSON body。
  /// Token 优先注入 queryParameters；如果提供了 [data] 则注入 data。
  /// **返回**: 解析后的 JSON Map。
  /// **抛出**: [ApiException] 或 [DioException]。
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    final token = _getToken();
    if (token != null) {
      if (queryParameters != null) {
        queryParameters['token'] = token;
      } else if (data != null) {
        data['token'] = token;
      }
    }
    final response = await _wrapHttpError(() => _dio.delete(
          path,
          queryParameters: queryParameters ??
              (token != null && data == null ? {'token': token} : null),
          data: data,
        ));
    return _validate(response);
  }

  /// 将 DioException 包装为 ApiException（仅当 [config.wrapHttpErrors] 为 true 时）。
  Future<Response<T>> _wrapHttpError<T>(
      Future<Response<T>> Function() fn) async {
    if (!config.wrapHttpErrors) return fn();
    try {
      return await fn();
    } on DioException catch (e) {
      final httpStatus = e.response?.statusCode;
      final responseData = e.response?.data;
      throw ApiException(
        _dioExceptionToErrorCode(e),
        httpStatus: httpStatus,
        responseData: responseData is Map<String, dynamic>
            ? responseData
            : null,
        innerException: e,
      );
    }
  }

  /// 将 DioException 映射为合适的错误码字符串。
  String _dioExceptionToErrorCode(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'timeout';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'network_error';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return GeneralErrorCodes.errorToken;
    if (statusCode == 429) return GeneralErrorCodes.tooManyRequests;
    if (statusCode != null && statusCode >= 500) {
      return GeneralErrorCodes.systemError;
    }
    return 'http_${statusCode ?? 0}';
  }

  /// 校验 Dio 响应。
  ///
  /// 检查服务器返回的 JSON 状态码。若 `status == "error"` 则抛出 [ApiException]。
  /// 在 [config.relaxedResponse] 模式下，响应格式容错。
  Map<String, dynamic> _validate(Response response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      if (config.relaxedResponse) {
        return <String, dynamic>{};
      }
      throw ApiException(
        GeneralErrorCodes.systemError,
        httpStatus: response.statusCode,
        responseData: data is Map<String, dynamic> ? data : null,
      );
    }
    if (data['status'] == 'error') {
      throw ApiException(
        data['message'] as String? ?? 'unknown_error',
        httpStatus: response.statusCode,
        responseData: data,
      );
    }
    return data;
  }

  /// 安全地从 JSON 取值，支持 [config.relaxedTypes] 模式。
  ///
  /// 在 [config.relaxedTypes] 模式下，如果 [key] 对应的值不是 [T] 类型，
  /// 静默返回 `null`。
  T? safeGet<T>(Map<String, dynamic> map, String key) {
    if (!config.relaxedTypes) return map[key] as T?;
    final value = map[key];
    if (value is T) return value;
    if (value == null) return null;
    if (T == int && value is num) return value.toInt() as T;
    if (T == double && value is num) return value.toDouble() as T;
    return null;
  }

  /// 安全地从 JSON 取值（带默认值），支持 [config.relaxedTypes] 模式。
  T safeGetOrDefault<T>(Map<String, dynamic> map, String key, T defaultValue) {
    return safeGet<T>(map, key) ?? defaultValue;
  }
}
