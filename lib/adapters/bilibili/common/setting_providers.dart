import 'package:riverpod/riverpod.dart';
import 'package:skf/pages/mine/controller.dart';
import 'package:skf/adapters/bilibili/pages/rcmd/controller.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/pages/download/controller.dart';
import 'package:skf/pages/fav/video/controller.dart';
import 'package:skf/adapters/bilibili/services/account_service.dart';

/// mainControllerProvider / homeControllerProvider now live in
/// pages/main/controller.dart / pages/home/controller.dart (real providers) —
/// the duplicate throwing stubs were removed to fix ambiguous imports.

final mineControllerProvider = Provider<MineController>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

final rcmdControllerProvider = Provider<RcmdController>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

final downloadPageControllerProvider = Provider<DownloadPageController>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

final favControllerProvider = Provider<FavController>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

final accountServiceProvider = Provider<AccountService>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});
