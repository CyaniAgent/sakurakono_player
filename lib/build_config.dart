import 'package:skf/core/app_meta.dart';

abstract final class BuildConfig {
  static const int versionCode = int.fromEnvironment(
    '${AppMeta.buildConfigPrefix}.code',
    defaultValue: 1,
  );
  static const String versionName = String.fromEnvironment(
    '${AppMeta.buildConfigPrefix}.name',
    defaultValue: 'SNAPSHOT',
  );

  static const int buildTime = int.fromEnvironment(
    '${AppMeta.buildConfigPrefix}.time',
  );
  static const String commitHash = String.fromEnvironment(
    '${AppMeta.buildConfigPrefix}.hash',
    defaultValue: 'N/A',
  );
}
