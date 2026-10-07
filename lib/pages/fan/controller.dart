import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/pages/follow_type/controller.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/repository/repository_providers.dart';

class FansController extends FollowTypeController {
  FansController(this.showName);
  final bool showName;
  late final bool isOwner;

  @override
  void init() {
    final Map? args = AppNavigator.arguments;
    final ownerMid = repoRef!.read(accountProvider).userId ?? 0;
    final int? mid = args?['mid'];
    this.mid = mid ?? ownerMid;
    isOwner = ownerMid == this.mid;
    if (showName && !isOwner) {
      final String? name = args?['name'];
      this.name = name;
      if (name == null) {
        queryUserName();
      }
    }
    queryData();
  }

  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    final result = await (repoRef!.read(fanRepositoryProvider)).fans(
      vmid: mid,
      pn: page,
      orderType: 'attention',
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
