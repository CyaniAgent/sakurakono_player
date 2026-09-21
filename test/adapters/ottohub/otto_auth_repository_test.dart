import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_auth_repository.dart';
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/auth_types.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

/// AccountProvider double that records credential updates without touching
/// Hive (GStorage is not initialized in tests).
class _FakeAccountProvider extends OttoAccountProvider {
  _FakeAccountProvider(super.client);

  int updateCalls = 0;
  int clearCalls = 0;
  String? lastUid;
  String? lastToken;
  String? lastUname;
  String? lastFace;

  @override
  Future<void> restoreFromCache() async {
    // GStorage/Hive is not initialized in tests.
  }

  @override
  void updateCredentials({
    required String uid,
    required String token,
    String? uname,
    String? face,
    String? username,
    String? password,
  }) {
    updateCalls++;
    lastUid = uid;
    lastToken = token;
    lastUname = uname;
    lastFace = face;
  }

  @override
  void clearCredentials() {
    clearCalls++;
  }
}

void main() {
  late FakeHttpAdapter fake;
  late OttohubClient client;
  late OttoAuthRepository repo;
  late _FakeAccountProvider provider;

  OttoAuthRepository makeRepo(Map<String, String> routes) {    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    client = OttohubClient(dio: dio);
    repo = OttoAuthRepository(client);
    return repo;
  }

  setUpAll(() {
    // Global container for appRead(ottoAccountProvider) inside the repo.
    // Single shared fake instance (Provider caches its value); counters
    // reset per-test in setUp.
    provider = _FakeAccountProvider(OttohubClient(dio: Dio()));
    appContainer = ProviderContainer(
      overrides: [ottoAccountProvider.overrideWithValue(provider)],
    );
  });

  setUp(() {
    provider
      ..updateCalls = 0
      ..clearCalls = 0
      ..lastUid = null
      ..lastToken = null
      ..lastUname = null
      ..lastFace = null;
  });

  group('OttoAuthRepository (implementation-level)', () {
    test('happy: loginByPassword stores the token and notifies the provider',
        () async {
      makeRepo(<String, String>{
        'POST /auth/login': fixture('ottohub/login_response'),
      });

      final result = await repo.loginByPassword(
        'user@example.com',
        'pw123',
        '',
        '',
      );

      expect(result['status'], 'ok');
      final data = result['data'] as Map;
      expect(data['mid'], 10086);
      expect(data['token'], 'tok_abc123');
      expect(data['face'], 'https://example.com/avatar.jpg');
      expect(data['uname'], 'user@example.com');
      // Token cached on the shared client.
      expect(client.token, 'tok_abc123');
      // Account provider notified with exact credentials.
      expect(provider.updateCalls, 1);
      expect(provider.lastUid, '10086');
      expect(provider.lastToken, 'tok_abc123');
      expect(provider.lastUname, 'user@example.com');
      expect(provider.lastFace, 'https://example.com/avatar.jpg');
      expect(fake.requestCount, 1);
    });

    test('error: loginByPassword surfaces API error without touching the token',
        () async {
      makeRepo(<String, String>{
        'POST /auth/login': fixture('ottohub/error_auth'),
      });

      final result = await repo.loginByPassword(
        'user@example.com',
        'wrong',
        '',
        '',
      );

      expect(result['status'], 'error');
      expect(result['message'], 'error_password');
      expect(client.token, isNull);
      expect(provider.updateCalls, 0);
      expect(fake.requestCount, 1);
    });

    test('edge: loginByPassword tolerates missing optional profile fields',
        () async {
      makeRepo(<String, String>{
        'POST /auth/login': fixture('ottohub/login_response_minimal'),
      });

      final result = await repo.loginByPassword('u@example.com', 'pw', '', '');

      expect(result['status'], 'ok');
      final data = result['data'] as Map;
      expect(data['mid'], 42);
      expect(data['token'], 't_42');
      expect(data['face'], isNull); // avatar_url missing
      expect(data['uname'], ''); // email missing
      expect(client.token, 't_42');
      expect(provider.lastUid, '42');
      expect(provider.lastUname, isNull);
      expect(provider.lastFace, isNull);
      expect(fake.requestCount, 1);
    });

    test('edge: logout clears the token locally without any HTTP', () async {
      makeRepo(const <String, String>{});
      client.token = 'tok_abc123';

      final result = await repo.logout(const CoreAccount());

      expect(result['status'], 'ok');
      expect(result.containsKey('data'), isFalse);
      expect(client.token, isNull);
      expect(provider.clearCalls, 1);
      expect(fake.requestCount, 0);
    });
  });
}
