import 'package:riverpod/riverpod.dart';
import 'package:skf/pages/rcmd/controller.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';

/// mainControllerProvider / homeControllerProvider now live in
/// pages/main/controller.dart / pages/home/controller.dart (real providers) —
/// the duplicate throwing stubs were removed to fix ambiguous imports.


final rcmdControllerProvider = Provider<RcmdController>((ref) {
  return RcmdController();
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  throw UnimplementedError('Provided by the active adapter bridge');
});
