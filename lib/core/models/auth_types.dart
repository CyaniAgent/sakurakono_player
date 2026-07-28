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
