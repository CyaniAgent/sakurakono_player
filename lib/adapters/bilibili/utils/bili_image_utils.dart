import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:math' as math;

import 'package:skf/adapters/bilibili/http/init.dart';
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
  static final _thumbRegex = RegExp(
    r'@(\d+[a-z]_?)*)(\..*)?$',
    caseSensitive: false,
  );

  /// Bilibili CDN thumbnail: rewrites `@672w_672h_1c.webp`-style suffixes to
  /// `<quality>q` form (e.g. `_1q.webp`) unless quality is 100 (original).
  static String thumbnailUrl(String? src, [int maxQuality = 1]) {
    if (src != null && maxQuality != 100) {
      maxQuality = math.max(maxQuality, 0);
      bool hasMatch = false;
      src = src.splitMapJoin(
        _thumbRegex,
        onMatch: (match) {
          hasMatch = true;
          String suffix = match.group(3) ?? '.webp';
          return '${match.group(1)}_${maxQuality}q$suffix';
        },
        onNonMatch: (String str) {
          return str;
        },
      );
      if (!hasMatch) {
        return src.http2https;
      }
    }
    return src.http2https;
  }

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
