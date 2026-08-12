import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/result/loading_state.dart';

// impossible — no SDK API (OttoHub 无此域)
/// Stub [ValidateRepository] — OttoHub has no CAPTCHA/geetest validation API.
class OttoValidateRepository implements ValidateRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<Map?>> gaiaVgateRegister(String vVoucher) async =>
      _err(const ApiException('not_implemented'));

  @override
  Future<LoadingState<Map?>> gaiaVgateValidate({
    required String challenge,
    required String seccode,
    required String token,
    required String validate,
  }) async =>
      _err(const ApiException('not_implemented'));
}