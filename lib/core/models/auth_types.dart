/// Core domain models for authentication operations.
///
/// These models are adapter-independent representations of authentication
/// data, used by [AuthRepository] and its implementations.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_types.freezed.dart';

/// Data about a logged-in device.
@freezed
abstract class CoreLoginDevicesData with _$CoreLoginDevicesData {
  const factory CoreLoginDevicesData({
    List<CoreLoginDevice>? devices,
  }) = _CoreLoginDevicesData;
}

/// A single login device entry.
@freezed
abstract class CoreLoginDevice with _$CoreLoginDevice {
  const factory CoreLoginDevice({
    String? deviceName,
    bool? isCurrentDevice,
    String? latestLoginAt,
    String? source,
  }) = _CoreLoginDevice;
}

/// Core representation of an account.
///
/// Adapter implementations map to/from the adapter's sealed Account hierarchy.
@freezed
abstract class CoreAccount with _$CoreAccount {
  const factory CoreAccount({
    @Default(false) bool isLogin,
    @Default(0) int mid,
    String? accessKey,
    @Default(false) bool activated,
  }) = _CoreAccount;
}

/// Status of a QR-code login poll.
enum CoreQrLoginStatus {
  /// Waiting for the user to scan/confirm.
  pending,

  /// Login confirmed by the user.
  confirmed,

  /// QR code expired or rejected.
  expired,

  /// Response shape could not be recognized.
  unknown,
}

/// Parsed result of a QR-code login poll.
///
/// Adapter [AuthRepository.pollQRCode] still returns a raw [Map]; this type
/// provides a lenient parser for that map (missing fields fall back to
/// defaults, never throws).
class CoreQrLoginResult {
  final CoreQrLoginStatus status;
  final int? mid;
  final String? accessToken;
  final String? refreshToken;
  final bool isLogin;

  const CoreQrLoginResult({
    this.status = CoreQrLoginStatus.unknown,
    this.mid,
    this.accessToken,
    this.refreshToken,
    this.isLogin = false,
  });

  factory CoreQrLoginResult.fromMap(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : const <String, dynamic>{};
    final status = rawData is Map
        ? switch (data['url']) {
            86090 => CoreQrLoginStatus.confirmed,
            86101 => CoreQrLoginStatus.expired,
            _ => CoreQrLoginStatus.pending,
          }
        : CoreQrLoginStatus.unknown;
    final isLogin = data['is_login'] as bool?
        ?? status == CoreQrLoginStatus.confirmed;
    return CoreQrLoginResult(
      status: status,
      mid: (data['mid'] as num?)?.toInt(),
      accessToken: (data['access_token'] ?? data['accessToken']) as String?,
      refreshToken: (data['refresh_token'] ?? data['refreshToken']) as String?,
      isLogin: isLogin,
    );
  }
}

/// Generic outcome of a login attempt.
@freezed
abstract class CoreLoginResult with _$CoreLoginResult {
  const factory CoreLoginResult({
    required bool success,
    String? message,
    CoreAccount? account,
  }) = _CoreLoginResult;
}
