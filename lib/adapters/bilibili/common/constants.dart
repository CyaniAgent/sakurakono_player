
abstract final class BiliConstants {
  // 27eb53fc9058f8c3  移动端 Android
  // 4409e2ce8ffd12b8  HD版
  static const String appKey = 'dfca71928277209b';
  // 59b43e04ad6965f34319062b478f83dd TV端
  static const String appSec = 'b5475a8825547a4fc26c7d518eaaa02e';

  static const String traceId =
      '11111111111111111111111111111111:1111111111111111:0:0';
  static const String userAgent =
      'Mozilla/5.0 BiliDroid/2.0.1 (bbcallen@gmail.com) os/android model/android_hd mobi_app/android_hd build/2001100 channel/master innerVer/2001100 osVer/15 network/2';
  static const String statistics =
      '{"appId":5,"platform":3,"version":"2.0.1","abtest":""}';

  static const String userAgentApp =
      'Mozilla/5.0 BiliDroid/8.43.0 (bbcallen@gmail.com) os/android model/android mobi_app/android build/8430300 channel/master innerVer/8430300 osVer/15 network/2';
  static const String statisticsApp =
      '{"appId":1,"platform":3,"version":"8.43.0","abtest":""}';

  static const baseHeaders = {
    'env': 'prod',
    'app-key': 'android64',
    'x-bili-aurora-zone': 'sh001',
  };

  static const goodsUrlPrefix = "https://gaoneng.bilibili.com/tetris";
  static const dynFeatures = 'itemOpusStyle,listOnlyfans,onlyfansQaCard';
}
