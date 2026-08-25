import 'package:riverpod/riverpod.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/pages/home/controller.dart';
import 'package:skf/pages/mine/controller.dart';
import 'package:skf/adapters/bilibili/pages/rcmd/controller.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/pages/download/controller.dart';
import 'package:skf/pages/fav/video/controller.dart';
import 'package:skf/adapters/bilibili/services/account_service.dart';

final mainControllerProvider = Provider<MainControllerNotifier>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

final homeControllerProvider = Provider<HomeControllerNotifier>((ref) {
  throw UnimplementedError('Obtained via Get.find in adapter bridge');
});

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
