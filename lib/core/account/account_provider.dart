/// Provides authentication state, profile info, and auth headers
/// for the currently active user account.
abstract class AccountProvider {
  bool get isLoggedIn;
  String? get userId;
  String? get displayName;
  String? get avatarUrl;
  Future<void> login();
  Future<void> logout();
  Map<String, String> get authHeaders;
  Map<String, String> get grpcMetadata;
  Stream<bool> onAuthStateChanged();
}
