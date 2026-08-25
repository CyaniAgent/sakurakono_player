import 'package:skf/pages/common/common_page.dart';
import 'package:skf/pages/fav/article/controller.dart';
import 'package:skf/pages/fav/cheese/controller.dart';
import 'package:skf/pages/fav/topic/controller.dart';
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
