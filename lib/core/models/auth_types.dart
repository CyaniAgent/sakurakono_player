/// Core domain models for authentication operations.
///
/// These models are adapter-independent representations of authentication
/// data, used by [AuthRepository] and its implementations.
library;

/// Data about a logged-in device.
class CoreLoginDevicesData {
  List<CoreLoginDevice>? devices;

  CoreLoginDevicesData({this.devices});
}

/// A single login device entry.
class CoreLoginDevice {
  String? deviceName;
  bool? isCurrentDevice;
  String? latestLoginAt;
  String? source;

  CoreLoginDevice({
    this.deviceName,
    this.isCurrentDevice,
    this.latestLoginAt,
    this.source,
  });
}

/// Core representation of an account.
///
/// Adapter implementations map to/from the adapter's sealed Account hierarchy.
class CoreAccount {
  final bool isLogin;
  final int mid;
  final String? accessKey;
  final bool activated;

  const CoreAccount({
    this.isLogin = false,
    this.mid = 0,
    this.accessKey,
    this.activated = false,
  });
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
class CoreLoginResult {
  final bool success;
  final String? message;
  final CoreAccount? account;

  const CoreLoginResult({
    required this.success,
    this.message,
    this.account,
  });
}
