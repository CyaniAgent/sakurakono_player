import 'dart:async';
import 'package:get/get.dart';

/// Adapter-agnostic account service interface.
/// Each platform adapter (Bilibili, OttoHub, etc.) provides its own implementation.
abstract class AccountProvider extends GetxService {
  /// User avatar URL (reactive).
  RxString get rxFace;
  /// Login state (reactive).
  RxBool get rxIsLogin;

  /// User avatar URL.
  String? get face;
  /// Whether the user is logged in.
  bool get isLogin;
  /// Current user ID.
  String? get userId;
  /// User display name.
  String? get displayName;

  /// Restore login state from local cache on startup.
  void restoreFromCache();

  /// Auth headers for API requests.
  Map<String, String> get authHeaders;
  /// gRPC metadata for gRPC requests.
  Map<String, String> get grpcMetadata;
  /// Stream of auth state changes.
  Stream<bool> onAuthStateChanged();
}
