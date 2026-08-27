import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/ui/image_preview_type.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/models/dynamics/article_content_model.dart'
    show ArticleContentModel; // ignore: adapter import
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/utils/extension/get_ext.dart';
import 'package:skf/utils/extension/num_ext.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/url_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class ArticleController extends CommonDynController {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late String id;
  late String type;

  late String url;
  late int commentId;
  @override
  int get oid => commentId;
  late int commentType;
  @override
  int get replyType => commentType;
  final summary = Summary();

  late int topIndex = 0;

  @override
  dynamic get sourceId => commentType == 12 ? 'cv' : id;

  bool isLoaded = false;
  CoreDynamicItemModel? opusData; // 标题信息从summary获取, 动态没有favorite
  CoreArticleViewData? articleData;
  final stats = Rxn<CoreModuleStatModel>();

  List<ArticleContentModel>? get opus {
    final coreContent =
        opusData?.modules?.moduleContent ?? articleData?.opus?.content;
    return coreContent?.map(ModelConverters.articleContent).toList();
  }

  List<CoreSourceModel>? _images;
  List<CoreSourceModel> images() => _images ??= opus!
      .where((e) => e.paraType == 2 && e.pic != null)
      .map((e) => CoreSourceModel(url: e.pic!.pics!.first.url!))
      .toList();

  ArticleController() {
    final params = Get.parameters;
    id = params['id']!;
    type = params['type']!;

    // to opus
    if (type == 'read') {
      UrlUtils.parseRedirectUrl('https://www.bilibili.com/read/cv/').then((url) {
        if (url != null) {
          final opusId = PiliScheme.uriDigitRegExp.firstMatch(url)?.group(1);
          if (opusId != null) {
            id = opusId;
            type = 'opus';
          }
          Get.putOrFind(() => this, tag: type + id);
        }
        init();
      });
    } else {
      init();
    }
  }

  void init() {
    url = type == 'read'
        ? 'https://www.bilibili.com/read/cv'
        : 'https://www.bilibili.com/opus/';
    commentType = type == 'picture' ? 11 : 12;

    _queryContent();
  }

  Future<bool> queryOpus(String opusId) async {
    final res = await (_ref!.read(dynamicsRepositoryProvider)).opusDetail(opusId: opusId);
    if (res case Success(:final response)) {
      //fallback
      if (response.fallback?.id != null) {
        id = response.fallback!.id!;
        type = 'read';
        init();
        return false;
      }
      opusData = response;
      commentType = response.basic!.commentType!;
      commentId = int.parse(response.basic!.commentIdStr!);
      if (showDynActionBar) {
        if (response.modules?.moduleStat != null) {
          stats.value = response.modules!.moduleStat;
        } else {
          getArticleInfo();
        }
      }
      summary
        ..author ??= response.modules?.moduleAuthor != null
            ? CoreAvatar(
                mid: response.modules!.moduleAuthor!.mid,
                name: response.modules!.moduleAuthor!.name,
                face: response.modules!.moduleAuthor!.face,
              )
            : null
        ..title ??= response.modules?.moduleTag?.text;
      return true;
    } else {
      loadingState = switch (res) {
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => const Error(null),
      };
      return false;
    }
  }

  Future<bool> queryRead(int cvid) async {
    final res = await (_ref!.read(dynamicsRepositoryProvider)).articleView(cvId: cvid.toString());
    if (res case Success(:final response)) {
      articleData = response;
      summary
        ..author ??= response.author
        ..title ??= response.title
        ..cover ??= response.originImageUrls?.firstOrNull;

      if (showDynActionBar) {
        getArticleInfo();
      }
      return true;
    } else {
      loadingState = switch (res) {
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => const Error(null),
      };
      return false;
    }
  }

  // stats
  Future<bool> getArticleInfo([bool isGetCover = false]) async {
    final res = await (_ref!.read(dynamicsRepositoryProvider)).articleInfo(cvId: commentId.toString());
    if (res case Success(:final response)) {
      summary
        ..cover ??= response.originImageUrls?.firstOrNull
        ..title ??= response.title;

      stats.value ??= CoreModuleStatModel(
        comment: CoreDynamicStat(count: response.stats?.reply),
        forward: CoreDynamicStat(count: response.stats?.share),
        like: CoreDynamicStat(
          count: response.stats?.like,
          status: response.stats?.like == 1,
        ),
        favorite: CoreDynamicStat(
          count: response.stats?.favorite,
          status: response.favorite,
        ),
      );
      return true;
    }
    if (isGetCover) {
      res.toast();
    }
    return false;
  }

  // 请求动态内容
  Future<void> _queryContent() async {
    if (type != 'read') {
      isLoaded = await queryOpus(id);
    } else {
      commentId = int.parse(id);
      commentType = 12;
      isLoaded = await queryRead(commentId);
    }
    if (isLoaded)
      queryData();
      if (Accounts.heartbeat.isLogin && !Pref.historyPause) {
        (_ref!.read(videoRepositoryProvider)).historyReport(aid: commentId.toString(), type: 5);
      }
    }
  }

  Future<void> onFav() async {
    final favorite = stats.value?.favorite;
    bool isFav = favorite?.status == true;
    final repos = _ref!.read(favRepositoryProvider);
    final res = type == 'read'
        ? isFav
          ? await repos.delFavArticle(id: commentId.toString())
          : await repos.addFavArticle(id: commentId.toString())
        : await repos.communityAction(opusId: id, action: isFav ? 4 : 3);
    if (res.isSuccess) {
      favorite?.status = !isFav;
      if (isFav) {
        favorite?.count--;
      } else {
        favorite?.count++;
      }
      stats.refresh();
      SmartDialog.showToast('收藏成功');
    } else {
      res.toast();
    }
  }

  Future<void> onLike() async {
    final like = stats.value?.like;
    bool isLike = like?.status == true;
    final res = await (_ref!.read(dynamicsRepositoryProvider)).thumbDynamic(
      dynamicId: opusData?.idStr ?? articleData?.dynIdStr,
      up: isLike ? 2 : 1,
    );
    if (res.isSuccess) {
      like?.status = !isLike;
      if (isLike) {
        like?.count--;
      } else {
        like?.count++;
      }
      stats.refresh();
      SmartDialog.showToast(!isLike ? '点赞成功' : '取消赞');
    } else {
      res.toast();
    }
  }

  @override
  Future<void> onReload() {
    if (!isLoaded) {
      return Future.syncValue(null);
    }
    return super.onReload();
  }
}

class Summary {
  CoreAvatar? author;
  String? title;
  String? cover;

  Summary({this.author, this.title, this.cover});
}
