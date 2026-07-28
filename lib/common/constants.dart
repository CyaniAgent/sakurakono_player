import 'package:skf/core/app_meta.dart';

abstract final class Constants {
  static String get appName => AppMeta.appName;
  static String get sourceCodeUrl => AppMeta.sourceCodeUrl;

  static final urlRegex = RegExp(
    r'https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]',
  );
}
