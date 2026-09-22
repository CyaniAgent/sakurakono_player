import 'package:skf/pages/common/common_page.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:skf/pages/fav/article/controller.dart';
import 'package:skf/pages/fav/cheese/controller.dart';
import 'package:skf/pages/fav/topic/controller.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/pages/zone/zone_host.dart';
import 'package:riverpod/riverpod.dart';

// ---------------------------------------------------------------------------
// Provider stubs for controllers resolved via appRead in pages/.
// Each placeholder throws at runtime — real instances are provided by the
// active adapter's Provider overrides during AdapterRegistry.activate().
// ---------------------------------------------------------------------------

final favArticleControllerProvider =
    Provider<FavArticleController>((ref) {
  throw UnimplementedError('Override via appRead');
});

final favTopicControllerProvider =
    Provider<FavTopicController>((ref) {
  throw UnimplementedError('Override via appRead');
});

final favCheeseControllerProvider =
    Provider<FavCheeseController>((ref) {
  throw UnimplementedError('Override via appRead');
});

final mainBarStateProvider = Provider<MainBarState>((ref) {
  throw UnimplementedError('Override via appRead');
});

final homeBarStateProvider = Provider<HomeBarState>((ref) {
  throw UnimplementedError('Override via appRead');
});

// ---------------------------------------------------------------------------
// Host / Actions providers (adapter-provided page integrations).
// Stubs throw until the active adapter overrides them in registerDependencies.
// ---------------------------------------------------------------------------

final videoHostProvider = Provider<VideoHost>((ref) {
  throw UnimplementedError('Override via appRead');
});

final settingHostProvider = Provider<SettingHost>((ref) {
  throw UnimplementedError('Override via appRead');
});

final memberHostProvider = Provider<MemberHost>((ref) {
  throw UnimplementedError('Override via appRead');
});

final mainHostProvider = Provider<MainHost>((ref) {
  throw UnimplementedError('Override via appRead');
});

final dynamicsHostProvider = Provider<DynamicsHost>((ref) {
  throw UnimplementedError('Override via appRead');
});

final zoneHostProvider = Provider<ZoneHost>((ref) {
  throw UnimplementedError('Override via appRead');
});

final mineActionsProvider = Provider<MineActions>((ref) {
  throw UnimplementedError('Override via appRead');
});

final downloadActionsProvider = Provider<DownloadActions>((ref) {
  throw UnimplementedError('Override via appRead');
});
