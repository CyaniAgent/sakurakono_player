import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:math' as math;

import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/utils/cache_manager.dart';
import 'package:skf/utils/extension/file_ext.dart';
import 'package:skf/utils/extension/string_ext.dart';
import 'package:skf/utils/image_utils.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:live_photo_maker/live_photo_maker.dart';

abstract final class BiliImageUtils {
  static String thumbnailUrl(String? src, [int maxQuality = 1]) =>
      ImageUtils.thumbnailUrl(
        src,
        maxQuality == 100 ? 100 : math.max(maxQuality, GlobalData().imgQuality),
      );

  static Future<bool> downloadLivePhoto({
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  }) async {
    try {
      if (PlatformUtils.isMobile &&
          !await ImageUtils.checkPermissionDependOnSdkInt()) {
        return false;
      }
      if (!ImageUtils.silentDownImg) {
        SmartDialog.showLoading(msg: '正在下载');
      }

      String videoName = "video_${Utils.getFileName(liveUrl)}";
      String videoPath = '$tmpDirPath/$videoName';

      final res = await Request().downloadFile(liveUrl.http2https, videoPath);
      if (res.statusCode != 200) throw '${res.statusCode}';

      if (Platform.isIOS) {
        final imageFile = await CacheManager.manager.getSingleFile(
          url.http2https,
        );
        if (!ImageUtils.silentDownImg) {
          SmartDialog.showLoading(msg: '正在保存');
        }
        bool success = await LivePhotoMaker.create(
          coverImage: imageFile.path,
          imagePath: null,
          voicePath: videoPath,
          width: width,
          height: height,
        ).whenComplete(File(videoPath).tryDel);
        if (success) {
          SmartDialog.showToast(' 已保存 ');
        } else {
          SmartDialog.showToast('保存失败');
          return false;
        }
      } else {
        if (!ImageUtils.silentDownImg) {
          SmartDialog.showLoading(msg: '正在保存');
        }
        await ImageUtils.saveFileImg(
          filePath: videoPath,
          fileName: videoName,
          type: FileType.video,
          needToast: true,
        );
      }
      return true;
    } catch (err) {
      SmartDialog.showToast(err.toString());
      return false;
    } finally {
      if (!ImageUtils.silentDownImg) {
        SmartDialog.dismiss(status: SmartStatus.loading);
      }
    }
  }
}
