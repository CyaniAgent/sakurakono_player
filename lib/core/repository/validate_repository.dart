import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for gaia validate (CAPTCHA) data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed.
abstract class ValidateRepository {
  /// Register a gaia vgate voucher for CAPTCHA verification.
  Future<LoadingState<Map?>> gaiaVgateRegister(String vVoucher);

  /// Validate a gaia vgate challenge with the given CAPTCHA tokens.
  Future<LoadingState<Map?>> gaiaVgateValidate({
    required dynamic challenge,
    required dynamic seccode,
    required dynamic token,
    required dynamic validate,
  });
}
