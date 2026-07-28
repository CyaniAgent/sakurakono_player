import 'package:dio/dio.dart';
import 'package:skf/adapters/bilibili/http/api.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [ValidateRepository] that delegates to HTTP APIs.
class BiliValidateRepository implements ValidateRepository {
  @override
  Future<LoadingState<Map?>> gaiaVgateRegister(String vVoucher) async {
    final res = await Request().post(
      Api.gaiaVgateRegister,
      queryParameters: {
        if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
      },
      data: {
        'v_voucher': vVoucher,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (res.data['code'] == 0) {
      return Success(res.data['data']);
    } else {
      return Error(res.data['message']);
    }
  }

  @override
  Future<LoadingState<Map?>> gaiaVgateValidate({
    required dynamic challenge,
    required dynamic seccode,
    required dynamic token,
    required dynamic validate,
  }) async {
    final res = await Request().post(
      Api.gaiaVgateValidate,
      queryParameters: {
        if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
      },
      data: {
        'challenge': challenge,
        'seccode': seccode,
        'token': token,
        'validate': validate,
      },
    );
    if (res.data['code'] == 0) {
      return Success(res.data['data']);
    } else {
      return Error(res.data['message']);
    }
  }
}
