// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum CoreContributeType {
  video,
  charging,
  season,
  series,
  bangumi,
  comic,
}

enum CoreArchiveOrderTypeApp {
  pubdate('最新发布'),
  click('最多播放');

  final String label;
  const CoreArchiveOrderTypeApp(this.label);
}

enum CoreArchiveSortTypeApp {
  desc('最新'),
  asc('最早');

  final String label;
  const CoreArchiveSortTypeApp(this.label);
}

enum CoreArchiveOrderTypeWeb {
  pubdate,
  click,
  stow,
}

enum CoreWebSsType {
  season,
  series,
}

// ---------------------------------------------------------------------------
// Space models
// ---------------------------------------------------------------------------

class CoreSpaceArticleData {
  int? count;
  List<CoreSpaceArticleItem>? item;
  int? listsCount;

  CoreSpaceArticleData({this.count, this.item, this.listsCount});

  factory CoreSpaceArticleData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceArticleData(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreSpaceArticleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        listsCount: json['lists_count'] as int?,
      );
}

class CoreSpaceArticleItem {
  String? title;
  CoreStats? coreStats;
  List<String>? originImageUrls;
  String? uri;
  String? publishTimeText;

  CoreSpaceArticleItem({
    this.title,
    this.coreStats,
    this.originImageUrls,
    this.uri,
    this.publishTimeText,
  });

  factory CoreSpaceArticleItem.fromJson(Map<String, dynamic> json) =>
      CoreSpaceArticleItem(
        title: json['title'] as String?,
        coreStats: json['CoreStats'] == null
            ? null
            : CoreStats.fromJson(json['CoreStats'] as Map<String, dynamic>),
        originImageUrls: (json['origin_image_urls'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        uri: json['uri'] as String?,
        publishTimeText: json['publish_time_text'] as String?,
      );
}

class CoreStats {
  int? view;
  int? reply;

  CoreStats({this.view, this.reply});

  factory CoreStats.fromJson(Map<String, dynamic> json) => CoreStats(
        view: json['view'] as int?,
        reply: json['reply'] as int?,
      );
}

class CoreSpaceSsData {
  CoreSpaceSsPage? corePage;
  List<CoreSpaceSsModel>? seasonsList;
  List<CoreSpaceSsModel>? seriesList;

  CoreSpaceSsData({this.corePage, this.seasonsList, this.seriesList});

  factory CoreSpaceSsData.fromJson(Map<String, dynamic> json) => CoreSpaceSsData(
        corePage: json['CorePage'] == null
            ? null
            : CoreSpaceSsPage.fromJson(json['CorePage'] as Map<String, dynamic>),
        seasonsList: (json['seasons_list'] as List<dynamic>?)
            ?.map((e) => CoreSpaceSsModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        seriesList: (json['series_list'] as List<dynamic>?)
            ?.map((e) => CoreSpaceSsModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreSpaceSsPage {
  int? total;

  CoreSpaceSsPage({this.total});

  factory CoreSpaceSsPage.fromJson(Map<String, dynamic> json) => CoreSpaceSsPage(
        total: json['total'] as int?,
      );
}

class CoreSpaceSsModel {
  CoreSpaceSsMeta? meta;

  CoreSpaceSsModel({this.meta});

  factory CoreSpaceSsModel.fromJson(Map<String, dynamic> json) => CoreSpaceSsModel(
        meta: json['meta'] == null
            ? null
            : CoreSpaceSsMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
}

class CoreSpaceSsMeta {
  String? cover;
  String? name;
  int? ptime;
  int? total;
  dynamic seasonId;
  dynamic seriesId;

  CoreSpaceSsMeta({
    this.cover,
    this.name,
    this.ptime,
    this.total,
    this.seasonId,
    this.seriesId,
  });

  factory CoreSpaceSsMeta.fromJson(Map<String, dynamic> json) => CoreSpaceSsMeta(
        cover: json['cover'] as String?,
        name: json['name'] as String?,
        ptime: json['ptime'] as int?,
        total: json['total'] as int?,
        seasonId: json['season_id'],
        seriesId: json['series_id'],
      );
}

class CoreSpaceArchiveData {
  CoreEpisodicButton? coreEpisodicButton;
  int? count;
  List<CoreSpaceArchiveItem>? item;
  bool? hasNext;
  bool? hasPrev;
  int? next;

  CoreSpaceArchiveData({
    this.coreEpisodicButton,
    this.count,
    this.item,
    this.hasNext,
    this.hasPrev,
    this.next,
  });

  factory CoreSpaceArchiveData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceArchiveData(
        coreEpisodicButton: json['episodic_button'] == null
            ? null
            : CoreEpisodicButton.fromJson(
                json['episodic_button'] as Map<String, dynamic>),
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreSpaceArchiveItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasNext: json['has_next'] as bool?,
        hasPrev: json['has_prev'] as bool?,
        next: json['next'] as int?,
      );
}

class CoreEpisodicButton {
  String? text;
  String? uri;

  CoreEpisodicButton({this.text, this.uri});

  factory CoreEpisodicButton.fromJson(Map<String, dynamic> json) => CoreEpisodicButton(
        text: json['text'] as String?,
        uri: json['uri'] as String?,
      );
}

class CoreSpaceArchiveItem {
  String? title;
  String? cover;
  String? uri;
  String? param;
  String? goto;
  String? length;
  int? duration;
  bool? isSteins;
  bool? isCooperation;
  bool? isPgc;
  bool? isPugv;
  String? bvid;
  int? cid;
  String? publishTimeText;
  List<CoreBadge>? badges;
  CoreSpaceArchiveSeason? season;
  CoreHistory? coreHistory;
  String? styles;
  String? label;
  int? play;
  int? danmaku;
  int? ownerMid;
  String? ownerName;

  CoreSpaceArchiveItem({
    this.title,
    this.cover,
    this.uri,
    this.param,
    this.goto,
    this.length,
    this.duration,
    this.isSteins,
    this.isCooperation,
    this.isPgc,
    this.isPugv,
    this.bvid,
    this.cid,
    this.publishTimeText,
    this.badges,
    this.season,
    this.coreHistory,
    this.styles,
    this.label,
    this.play,
    this.danmaku,
    this.ownerMid,
    this.ownerName,
  });

  factory CoreSpaceArchiveItem.fromJson(Map<String, dynamic> json) =>
      CoreSpaceArchiveItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        uri: json['uri'] as String?,
        param: json['param'] as String?,
        goto: json['goto'] as String?,
        length: json['length'] as String?,
        duration: json['duration'] as int? ?? -1,
        isSteins: json['is_steins'] as bool?,
        isCooperation: json['is_cooperation'] as bool?,
        isPgc: json['is_pgc'] as bool?,
        isPugv: json['is_pugv'] as bool?,
        bvid: json['bvid'] as String?,
        cid: json['first_cid'] as int?,
        publishTimeText: json['publish_time_text'] as String?,
        badges: (json['badges'] as List<dynamic>?)
            ?.map((e) => CoreBadge.fromJson(e as Map<String, dynamic>))
            .toList(),
        season: json['season'] == null
            ? null
            : CoreSpaceArchiveSeason.fromJson(
                json['season'] as Map<String, dynamic>),
        coreHistory: json['CoreHistory'] == null
            ? null
            : CoreHistory.fromJson(json['CoreHistory'] as Map<String, dynamic>),
        styles: json['styles'] as String?,
        label: json['label'] as String?,
        play: json['play'] as int?,
        danmaku: json['danmaku'] as int?,
        ownerMid: json['mid'] as int?,
        ownerName: json['author'] as String?,
      );
}

class CoreBadge {
  String? text;

  CoreBadge({this.text});

  factory CoreBadge.fromJson(Map<String, dynamic> json) => CoreBadge(
        text: json['text'] as String?,
      );
}

class CoreSpaceArchiveSeason {
  dynamic mtime;

  CoreSpaceArchiveSeason({this.mtime});

  factory CoreSpaceArchiveSeason.fromJson(Map<String, dynamic> json) =>
      CoreSpaceArchiveSeason(
        mtime: json['mtime'],
      );
}

class CoreHistory {
  int? progress;
  int? duration;

  CoreHistory({this.progress, this.duration});

  factory CoreHistory.fromJson(Map<String, dynamic> json) => CoreHistory(
        progress: json['progress'] as int?,
        duration: json['duration'] as int?,
      );
}

class CoreSpaceAudioData {
  int? totalSize;
  List<CoreSpaceAudioItem>? items;

  CoreSpaceAudioData({this.totalSize, this.items});

  factory CoreSpaceAudioData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceAudioData(
        totalSize: json['totalSize'] as int?,
        items: (json['data'] as List<dynamic>?)
            ?.map((e) => CoreSpaceAudioItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreSpaceAudioItem {
  int? id;
  int? uid;
  String? title;
  String? cover;
  String? author;

  CoreSpaceAudioItem({this.id, this.uid, this.title, this.cover, this.author});

  factory CoreSpaceAudioItem.fromJson(Map<String, dynamic> json) =>
      CoreSpaceAudioItem(
        id: json['id'] as int?,
        uid: json['uid'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        author: json['author'] as String?,
      );
}

class CoreSpaceCheeseData {
  List<CoreSpaceCheeseItem>? items;
  CoreSpaceCheesePage? corePage;

  CoreSpaceCheeseData({this.items, this.corePage});

  factory CoreSpaceCheeseData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceCheeseData(
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreSpaceCheeseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        corePage: json['CorePage'] == null
            ? null
            : CoreSpaceCheesePage.fromJson(json['CorePage'] as Map<String, dynamic>),
      );
}

class CoreSpaceCheeseItem {
  int? id;
  String? title;
  String? cover;
  String? subtitle;

  CoreSpaceCheeseItem({this.id, this.title, this.cover, this.subtitle});

  factory CoreSpaceCheeseItem.fromJson(Map<String, dynamic> json) =>
      CoreSpaceCheeseItem(
        id: json['id'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        subtitle: json['subtitle'] as String?,
      );
}

class CoreSpaceCheesePage {
  int? total;
  int? num;

  CoreSpaceCheesePage({this.total, this.num});

  factory CoreSpaceCheesePage.fromJson(Map<String, dynamic> json) =>
      CoreSpaceCheesePage(
        total: json['total'] as int?,
        num: json['num'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Space overview
// ---------------------------------------------------------------------------

class CoreSpaceData {
  int? relation;
  int? guestRelation;
  int? medal;
  String? defaultTab;
  CoreSpaceSetting? setting;
  CoreSpaceTab? tab;
  CoreSpaceCard? coreCard;
  CoreSpaceImages? images;
  CoreLive? coreLive;
  CoreElec? coreElec;
  CoreArchive? coreArchive;
  CoreSpaceSeries? series;
  CoreArticle? coreArticle;
  CoreSpaceSeason? season;
  CoreCoinArchive? coreCoinArchive;
  CoreLikeArchive? coreLikeArchive;
  CoreAudios? coreAudios;
  CoreFavourite2? coreFavourite2;
  CoreComic? coreComic;
  CoreUgcSeason? coreUgcSeason;
  CoreCheese? coreCheese;
  CoreGuard? coreGuard;
  List<CoreSpaceTab2>? tab2;
  int? relSpecial;
  bool? hasItem;
  List<CoreReservationCardItem>? reservationCardList;

  CoreSpaceData({
    this.relation,
    this.guestRelation,
    this.medal,
    this.defaultTab,
    this.setting,
    this.tab,
    this.coreCard,
    this.images,
    this.coreLive,
    this.coreElec,
    this.coreArchive,
    this.series,
    this.coreArticle,
    this.season,
    this.coreCoinArchive,
    this.coreLikeArchive,
    this.coreAudios,
    this.coreFavourite2,
    this.coreComic,
    this.coreUgcSeason,
    this.coreCheese,
    this.coreGuard,
    this.tab2,
    this.relSpecial,
    this.reservationCardList,
  });

  factory CoreSpaceData.fromJson(Map<String, dynamic> json) => CoreSpaceData(
        relation: json['relation'] as int?,
        guestRelation: json['guest_relation'] as int?,
        medal: json['medal'] as int?,
        defaultTab: json['default_tab'] as String?,
        setting: json['setting'] == null
            ? null
            : CoreSpaceSetting.fromJson(json['setting'] as Map<String, dynamic>),
        tab: json['tab'] == null
            ? null
            : CoreSpaceTab.fromJson(json['tab'] as Map<String, dynamic>),
        coreCard: json['CoreCard'] == null
            ? null
            : CoreSpaceCard.fromJson(json['CoreCard'] as Map<String, dynamic>),
        images: json['images'] == null
            ? null
            : CoreSpaceImages.fromJson(json['images'] as Map<String, dynamic>),
        coreLive: json['CoreLive'] == null
            ? null
            : CoreLive.fromJson(json['CoreLive'] as Map<String, dynamic>),
        coreElec: json['CoreElec'] == null
            ? null
            : CoreElec.fromJson(json['CoreElec'] as Map<String, dynamic>),
        coreArchive: json['CoreArchive'] == null
            ? null
            : CoreArchive.fromJson(json['CoreArchive'] as Map<String, dynamic>),
        series: json['series'] == null
            ? null
            : CoreSpaceSeries.fromJson(json['series'] as Map<String, dynamic>),
        coreArticle: json['CoreArticle'] == null
            ? null
            : CoreArticle.fromJson(json['CoreArticle'] as Map<String, dynamic>),
        season: json['season'] == null
            ? null
            : CoreSpaceSeason.fromJson(json['season'] as Map<String, dynamic>),
        coreCoinArchive: json['coin_archive'] == null
            ? null
            : CoreCoinArchive.fromJson(
                json['coin_archive'] as Map<String, dynamic>),
        coreLikeArchive: json['like_archive'] == null
            ? null
            : CoreLikeArchive.fromJson(
                json['like_archive'] as Map<String, dynamic>),
        coreAudios: json['CoreAudios'] == null
            ? null
            : CoreAudios.fromJson(json['CoreAudios'] as Map<String, dynamic>),
        coreFavourite2: json['CoreFavourite2'] == null
            ? null
            : CoreFavourite2.fromJson(json['CoreFavourite2'] as Map<String, dynamic>),
        coreComic: json['CoreComic'] == null
            ? null
            : CoreComic.fromJson(json['CoreComic'] as Map<String, dynamic>),
        coreUgcSeason: json['ugc_season'] == null
            ? null
            : CoreUgcSeason.fromJson(json['ugc_season'] as Map<String, dynamic>),
        coreCheese: json['CoreCheese'] == null
            ? null
            : CoreCheese.fromJson(json['CoreCheese'] as Map<String, dynamic>),
        coreGuard: json['CoreGuard'] == null
            ? null
            : CoreGuard.fromJson(json['CoreGuard'] as Map<String, dynamic>),
        tab2: (json['tab2'] as List<dynamic>?)
            ?.map((e) => CoreSpaceTab2.fromJson(e as Map<String, dynamic>))
            .toList(),
        relSpecial: (json['rel_special'] as num?)?.toInt(),
        reservationCardList: (json['reservation_card_list'] as List<dynamic>?)
            ?.map((e) => CoreReservationCardItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreSpaceSetting {
  int? like;
  int? attention;
  int? space;
  int? favVideo;
  int? coinsVideo;
  int? likesVideo;
  int? bangumi;

  CoreSpaceSetting({
    this.like,
    this.attention,
    this.space,
    this.favVideo,
    this.coinsVideo,
    this.likesVideo,
    this.bangumi,
  });

  factory CoreSpaceSetting.fromJson(Map<String, dynamic> json) => CoreSpaceSetting(
        like: json['like'] as int?,
        attention: json['attention'] as int?,
        space: json['space'] as int?,
        favVideo: json['fav_video'] as int?,
        coinsVideo: json['coins_video'] as int?,
        likesVideo: json['likes_video'] as int?,
        bangumi: json['bangumi'] as int?,
      );
}

class CoreSpaceTab {
  String? name;
  String? uri;

  CoreSpaceTab({this.name, this.uri});

  factory CoreSpaceTab.fromJson(Map<String, dynamic> json) => CoreSpaceTab(
        name: json['name'] as String?,
        uri: json['uri'] as String?,
      );
}

class CoreSpaceCard {
  String? face;
  String? name;
  int? mid;
  dynamic relation;
  int? silence;
  CoreVip? vip;

  CoreSpaceCard({
    this.face,
    this.name,
    this.mid,
    this.relation,
    this.silence,
    this.vip,
  });

  factory CoreSpaceCard.fromJson(Map<String, dynamic> json) => CoreSpaceCard(
        face: json['face'] as String?,
        name: json['name'] as String?,
        mid: json['mid'] as int?,
        relation: json['relation'],
        silence: json['silence'] as int?,
        vip: json['vip'] == null
            ? null
            : CoreVip.fromJson(json['vip'] as Map<String, dynamic>),
      );
}

class CoreSpaceImages {
  int? imgCount;

  CoreSpaceImages({this.imgCount});

  factory CoreSpaceImages.fromJson(Map<String, dynamic> json) => CoreSpaceImages(
        imgCount: json['img_count'] as int?,
      );
}

class CoreLive {
  int? liveStatus;

  CoreLive({this.liveStatus});

  factory CoreLive.fromJson(Map<String, dynamic> json) => CoreLive(
        liveStatus: json['liveStatus'] as int?,
      );
}

class CoreElec {
  int? total;
  List<dynamic>? list;

  CoreElec({this.total, this.list});

  factory CoreElec.fromJson(Map<String, dynamic> json) => CoreElec(
        total: json['total'] as int?,
        list: json['list'] as List<dynamic>?,
      );
}

class CoreArchive {
  int? count;
  List<CoreArchiveItem>? item;

  CoreArchive({this.count, this.item});

  factory CoreArchive.fromJson(Map<String, dynamic> json) => CoreArchive(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreArchiveItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreArchiveItem {
  String? title;
  String? cover;
  int? play;

  CoreArchiveItem({this.title, this.cover, this.play});

  factory CoreArchiveItem.fromJson(Map<String, dynamic> json) => CoreArchiveItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        play: json['play'] as int?,
      );
}

class CoreSpaceSeries {
  int? count;
  List<CoreSeriesItem>? item;

  CoreSpaceSeries({this.count, this.item});

  factory CoreSpaceSeries.fromJson(Map<String, dynamic> json) => CoreSpaceSeries(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreSeriesItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreSeriesItem {
  String? title;
  String? cover;
  int? seriesId;

  CoreSeriesItem({this.title, this.cover, this.seriesId});

  factory CoreSeriesItem.fromJson(Map<String, dynamic> json) => CoreSeriesItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        seriesId: json['series_id'] as int?,
      );
}

class CoreArticle {
  int? count;
  List<CoreArticleItem>? item;

  CoreArticle({this.count, this.item});

  factory CoreArticle.fromJson(Map<String, dynamic> json) => CoreArticle(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreArticleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreArticleItem {
  String? title;
  String? cover;

  CoreArticleItem({this.title, this.cover});

  factory CoreArticleItem.fromJson(Map<String, dynamic> json) => CoreArticleItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreSpaceSeason {
  int? count;
  List<CoreSpaceArchiveItem>? item;

  CoreSpaceSeason({this.count, this.item});

  factory CoreSpaceSeason.fromJson(Map<String, dynamic> json) => CoreSpaceSeason(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreSpaceArchiveItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreSeasonItem {
  String? title;
  String? cover;

  CoreSeasonItem({this.title, this.cover});

  factory CoreSeasonItem.fromJson(Map<String, dynamic> json) => CoreSeasonItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreCoinArchive {
  int? count;
  List<CoreCoinArchiveItem>? item;

  CoreCoinArchive({this.count, this.item});

  factory CoreCoinArchive.fromJson(Map<String, dynamic> json) => CoreCoinArchive(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreCoinArchiveItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreCoinArchiveItem {
  String? title;
  String? cover;

  CoreCoinArchiveItem({this.title, this.cover});

  factory CoreCoinArchiveItem.fromJson(Map<String, dynamic> json) =>
      CoreCoinArchiveItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreLikeArchive {
  int? count;
  List<CoreLikeArchiveItem>? item;

  CoreLikeArchive({this.count, this.item});

  factory CoreLikeArchive.fromJson(Map<String, dynamic> json) => CoreLikeArchive(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreLikeArchiveItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreLikeArchiveItem {
  String? title;
  String? cover;

  CoreLikeArchiveItem({this.title, this.cover});

  factory CoreLikeArchiveItem.fromJson(Map<String, dynamic> json) =>
      CoreLikeArchiveItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreAudios {
  int? count;
  List<CoreAudioItem>? item;

  CoreAudios({this.count, this.item});

  factory CoreAudios.fromJson(Map<String, dynamic> json) => CoreAudios(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreAudioItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreAudioItem {
  String? title;
  String? cover;

  CoreAudioItem({this.title, this.cover});

  factory CoreAudioItem.fromJson(Map<String, dynamic> json) => CoreAudioItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreFavourite2 {
  int? count;
  List<CoreFavouriteItem>? item;

  CoreFavourite2({this.count, this.item});

  factory CoreFavourite2.fromJson(Map<String, dynamic> json) => CoreFavourite2(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreFavouriteItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreFavouriteItem {
  String? title;
  String? cover;

  CoreFavouriteItem({this.title, this.cover});

  factory CoreFavouriteItem.fromJson(Map<String, dynamic> json) => CoreFavouriteItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreComic {
  int? count;
  List<CoreComicItem>? item;

  CoreComic({this.count, this.item});

  factory CoreComic.fromJson(Map<String, dynamic> json) => CoreComic(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreComicItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreComicItem {
  String? title;
  String? cover;

  CoreComicItem({this.title, this.cover});

  factory CoreComicItem.fromJson(Map<String, dynamic> json) => CoreComicItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreUgcSeason {
  int? count;
  List<CoreUgcSeasonItem>? item;

  CoreUgcSeason({this.count, this.item});

  factory CoreUgcSeason.fromJson(Map<String, dynamic> json) => CoreUgcSeason(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreUgcSeasonItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreUgcSeasonItem {
  String? title;
  String? cover;

  CoreUgcSeasonItem({this.title, this.cover});

  factory CoreUgcSeasonItem.fromJson(Map<String, dynamic> json) => CoreUgcSeasonItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreCheese {
  int? count;
  List<CoreCheeseItem>? item;

  CoreCheese({this.count, this.item});

  factory CoreCheese.fromJson(Map<String, dynamic> json) => CoreCheese(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreCheeseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreCheeseItem {
  String? title;
  String? cover;

  CoreCheeseItem({this.title, this.cover});

  factory CoreCheeseItem.fromJson(Map<String, dynamic> json) => CoreCheeseItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
      );
}

class CoreGuard {
  int? count;
  List<CoreSpaceGuardItem>? item;

  CoreGuard({this.count, this.item});

  factory CoreGuard.fromJson(Map<String, dynamic> json) => CoreGuard(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) => CoreSpaceGuardItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreSpaceGuardItem {
  String? name;
  String? face;

  CoreSpaceGuardItem({this.name, this.face});

  factory CoreSpaceGuardItem.fromJson(Map<String, dynamic> json) => CoreSpaceGuardItem(
        name: json['name'] as String?,
        face: json['face'] as String?,
      );
}

class CoreSpaceTab2 {
  String? name;
  String? uri;
  String? title;
  String? param;
  List<dynamic>? items;

  CoreSpaceTab2({this.name, this.uri, this.title, this.param, this.items});

  factory CoreSpaceTab2.fromJson(Map<String, dynamic> json) => CoreSpaceTab2(
        name: json['name'] as String?,
        uri: json['uri'] as String?,
        title: json['title'] as String?,
        param: json['param'] as String?,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
      );
}

class CoreReservationCardItem {
  int? rid;
  String? title;

  CoreReservationCardItem({this.rid, this.title});

  factory CoreReservationCardItem.fromJson(Map<String, dynamic> json) =>
      CoreReservationCardItem(
        rid: json['rid'] as int?,
        title: json['title'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Member info
// ---------------------------------------------------------------------------

class CoreMemberInfoModel {
  int? mid;
  String? name;
  String? sex;
  String? face;
  String? sign;
  int? level;
  bool? isFollowed;
  String? topPhoto;
  CoreBaseOfficialVerify? official;
  CoreVip? coreVip;
  CoreLiveRoom? coreLiveRoom;
  int? isSeniorMember;

  CoreMemberInfoModel({
    this.mid,
    this.name,
    this.sex,
    this.face,
    this.sign,
    this.level,
    this.isFollowed,
    this.topPhoto,
    this.official,
    this.coreVip,
    this.coreLiveRoom,
    this.isSeniorMember,
  });

  factory CoreMemberInfoModel.fromJson(Map<String, dynamic> json) =>
      CoreMemberInfoModel(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        sex: json['sex'] as String?,
        face: json['face'] as String?,
        sign: json['sign'] as String?,
        level: json['level'] as int?,
        isFollowed: json['is_followed'] as bool?,
        topPhoto: json['top_photo'] as String?,
        official: json['official'] == null
            ? null
            : CoreBaseOfficialVerify.fromJson(
                json['official'] as Map<String, dynamic>),
        coreVip: json['CoreVip'] == null
            ? null
            : CoreVip.fromJson(json['CoreVip'] as Map<String, dynamic>),
        coreLiveRoom: json['live_room'] == null
            ? null
            : CoreLiveRoom.fromJson(json['live_room'] as Map<String, dynamic>),
        isSeniorMember: json['is_senior_member'] as int?,
      );
}

class CoreBaseOfficialVerify {
  int? type;
  String? coreDesc;

  CoreBaseOfficialVerify({this.type, this.coreDesc});

  factory CoreBaseOfficialVerify.fromJson(Map<String, dynamic> json) =>
      CoreBaseOfficialVerify(
        type: json['type'] as int?,
        coreDesc: json['CoreDesc'] as String?,
      );
}

class CoreVip {
  int? type;
  int? status;
  int? vipType;
  int? vipStatus;

  CoreVip({this.type, this.status, this.vipType, this.vipStatus});

  factory CoreVip.fromJson(Map<String, dynamic> json) => CoreVip(
        type: json['type'] as int?,
        status: json['status'] as int?,
        vipType: json['vipType'] as int?,
        vipStatus: json['vipStatus'] as int?,
      );
}

class CoreLiveRoom {
  int? roomStatus;
  int? liveStatus;
  String? url;
  String? title;
  String? cover;
  int? roomId;
  int? roundStatus;
  CoreWatchedShow? coreWatchedShow;

  CoreLiveRoom({
    this.roomStatus,
    this.liveStatus,
    this.url,
    this.title,
    this.cover,
    this.roomId,
    this.roundStatus,
    this.coreWatchedShow,
  });

  factory CoreLiveRoom.fromJson(Map<String, dynamic> json) => CoreLiveRoom(
        roomStatus: json['roomStatus'] as int?,
        liveStatus: json['liveStatus'] as int?,
        url: json['url'] as String?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        roomId: json['roomid'] as int?,
        roundStatus: json['roundStatus'] as int?,
        coreWatchedShow: json['watched_show'] == null
            ? null
            : CoreWatchedShow.fromJson(
                json['watched_show'] as Map<String, dynamic>),
      );
}

class CoreWatchedShow {
  int? num;
  String? text;

  CoreWatchedShow({this.num, this.text});

  factory CoreWatchedShow.fromJson(Map<String, dynamic> json) => CoreWatchedShow(
        num: json['num'] as int?,
        text: json['text'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Member CoreCard info
// ---------------------------------------------------------------------------

class CoreMemberCardInfoData {
  CoreCard? coreCard;
  CoreCard? card;
  int? archiveCount;
  int? follower;

  CoreMemberCardInfoData({this.coreCard, this.card, this.archiveCount, this.follower});

  factory CoreMemberCardInfoData.fromJson(Map<String, dynamic> json) =>
      CoreMemberCardInfoData(
        coreCard: json['CoreCard'] == null
            ? null
            : CoreCard.fromJson(json['CoreCard'] as Map<String, dynamic>),
        card: json['card'] == null
            ? null
            : CoreCard.fromJson(json['card'] as Map<String, dynamic>),
        archiveCount: json['archive_count'] as int?,
        follower: json['follower'] as int?,
      );
}

class CoreCard {
  String? mid;
  String? name;
  String? face;
  CoreBaseOfficialVerify? official;
  CoreVip? coreVip;

  CoreCard({this.mid, this.name, this.face, this.official, this.coreVip});

  factory CoreCard.fromJson(Map<String, dynamic> json) => CoreCard(
        mid: json['mid'] as String?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        official: json['Official'] == null
            ? null
            : CoreBaseOfficialVerify.fromJson(
                json['Official'] as Map<String, dynamic>),
        coreVip: json['CoreVip'] == null
            ? null
            : CoreVip.fromJson(json['CoreVip'] as Map<String, dynamic>),
      );
}

// ---------------------------------------------------------------------------
// Search CoreArchive
// ---------------------------------------------------------------------------

class CoreSearchArchiveData {
  CoreSearchArchiveList? list;
  CorePage? corePage;

  CoreSearchArchiveData({this.list, this.corePage});

  factory CoreSearchArchiveData.fromJson(Map<String, dynamic> json) =>
      CoreSearchArchiveData(
        list: json['list'] == null
            ? null
            : CoreSearchArchiveList.fromJson(
                json['list'] as Map<String, dynamic>),
        corePage: json['CorePage'] == null
            ? null
            : CorePage.fromJson(json['CorePage'] as Map<String, dynamic>),
      );
}

class CoreSearchArchiveList {
  List<CoreListTag>? tags;
  List<CoreVListItemModel>? vlist;

  CoreSearchArchiveList({this.tags, this.vlist});

  factory CoreSearchArchiveList.fromJson(Map<String, dynamic> json) =>
      CoreSearchArchiveList(
        vlist: (json['vlist'] as List<dynamic>?)
            ?.map((e) => CoreVListItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        tags: (json['slist'] as List<dynamic>?)
            ?.map((e) => CoreListTag.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreListTag {
  int? tid;
  int? count;
  String? name;
  String? specialType;

  CoreListTag({this.tid, this.count, this.name, this.specialType});

  factory CoreListTag.fromJson(Map<String, dynamic> json) => CoreListTag(
        tid: json['tid'] as int?,
        count: json['count'] as int?,
        name: json['name'] as String?,
        specialType: json['special_type'] as String?,
      );
}

class CoreVListItemModel {
  String? title;
  String? author;
  String? corePic;
  String? bvid;
  int? play;
  int? videoReview;

  CoreVListItemModel({
    this.title,
    this.author,
    this.corePic,
    this.bvid,
    this.play,
    this.videoReview,
  });

  factory CoreVListItemModel.fromJson(Map<String, dynamic> json) =>
      CoreVListItemModel(
        title: json['title'] as String?,
        author: json['author'] as String?,
        corePic: json['CorePic'] as String?,
        bvid: json['bvid'] as String?,
        play: json['play'] as int?,
        videoReview: json['video_review'] as int?,
      );
}

class CorePage {
  int? count;
  int? total;

  CorePage({this.count, this.total});

  factory CorePage.fromJson(Map<String, dynamic> json) => CorePage(
        count: json['count'] as int?,
        total: json['total'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Season web
// ---------------------------------------------------------------------------

class CoreSeasonWebData {
  List<CoreSeasonArchive>? archives;
  CorePage? corePage;

  CoreSeasonWebData({this.archives, this.corePage});

  factory CoreSeasonWebData.fromJson(Map<String, dynamic> json) =>
      CoreSeasonWebData(
        archives: (json['archives'] as List<dynamic>?)
            ?.map((e) => CoreSeasonArchive.fromJson(e as Map<String, dynamic>))
            .toList(),
        corePage: json['CorePage'] == null
            ? null
            : CorePage.fromJson(json['CorePage'] as Map<String, dynamic>),
      );
}

class CoreSeasonArchive {
  int? aid;
  String? bvid;
  String? cover;
  String? title;
  int? pubdate;
  int? duration;
  int? view;
  int? danmu;
  int? ownerMid;

  CoreSeasonArchive({
    this.aid,
    this.bvid,
    this.cover,
    this.title,
    this.pubdate,
    this.duration,
    this.view,
    this.danmu,
    this.ownerMid,
  });

  factory CoreSeasonArchive.fromJson(Map<String, dynamic> json) => CoreSeasonArchive(
        aid: json['aid'] as int?,
        bvid: json['bvid'] as String?,
        cover: json['CorePic'] as String?,
        title: json['title'] as String?,
        pubdate: json['pubdate'] as int?,
        duration: json['duration'] as int?,
        view: json['view'] as int?,
        danmu: json['danmaku'] as int?,
        ownerMid: json['upMid'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Dynamics (shared with member repo)
// ---------------------------------------------------------------------------

class CoreDynamicsDataModel {
  bool? hasMore;
  List<CoreDynamicItemModel>? items;
  String? offset;
  int? total;
  bool? loadNext;

  CoreDynamicsDataModel({
    this.hasMore,
    this.items,
    this.offset,
    this.total,
    this.loadNext,
  });

  factory CoreDynamicsDataModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicsDataModel(
        hasMore: json['has_more'] as bool?,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreDynamicItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        offset: json['offset'] as String?,
        total: json['total'] as int?,
      );
}

class CoreDynamicItemModel {
  CoreBasic? basic;
  dynamic idStr;
  CoreItemModulesModel? modules;
  CoreDynamicItemModel? orig;
  String? type;
  bool? visible;
  CoreFallback? coreFallback;

  CoreDynamicItemModel({
    this.basic,
    this.idStr,
    this.modules,
    this.orig,
    this.type,
    this.visible,
    this.coreFallback,
  });

  factory CoreDynamicItemModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicItemModel(
        basic: json['basic'] == null
            ? null
            : CoreBasic.fromJson(json['basic'] as Map<String, dynamic>),
        idStr: json['id_str'],
        modules: json['modules'] == null
            ? null
            : CoreItemModulesModel.fromJson(
                json['modules'] as Map<String, dynamic>),
        orig: json['orig'] == null
            ? null
            : CoreDynamicItemModel.fromJson(json['orig'] as Map<String, dynamic>),
        type: json['type'] as String?,
        visible: json['visible'] as bool?,
        coreFallback: json['CoreFallback'] == null
            ? null
            : CoreFallback.fromJson(json['CoreFallback'] as Map<String, dynamic>),
      );
}

class CoreBasic {
  String? commentIdStr;
  int? commentType;
  String? ridStr;

  CoreBasic({this.commentIdStr, this.commentType, this.ridStr});

  factory CoreBasic.fromJson(Map<String, dynamic> json) => CoreBasic(
        commentIdStr: json['comment_id_str'] as String?,
        commentType: json['comment_type'] as int?,
        ridStr: json['rid_str'] as String?,
      );
}

class CoreFallback {
  String? id;

  CoreFallback({this.id});

  factory CoreFallback.fromJson(Map<String, dynamic> json) => CoreFallback(
        id: json['id'] as String?,
      );
}

class CoreItemModulesModel {
  CoreModuleAuthorModel? moduleAuthor;
  CoreModuleStatModel? moduleStat;
  CoreModuleTag? coreModuleTag;
  CoreModuleDynamicModel? moduleDynamic;
  CoreModuleInteraction? coreModuleInteraction;
  CoreModuleDispute? coreModuleDispute;
  CoreModuleTop? coreModuleTop;
  CoreModuleCollection? coreModuleCollection;
  List<CoreModuleTag>? moduleExtend;
  List<CoreArticleContentModel>? moduleContent;
  CoreModuleBlocked? coreModuleBlocked;
  CoreModuleFold? coreModuleFold;

  CoreItemModulesModel({
    this.moduleAuthor,
    this.moduleStat,
    this.coreModuleTag,
    this.moduleDynamic,
    this.coreModuleInteraction,
    this.coreModuleDispute,
    this.coreModuleTop,
    this.coreModuleCollection,
    this.moduleExtend,
    this.moduleContent,
    this.coreModuleBlocked,
    this.coreModuleFold,
  });

  factory CoreItemModulesModel.fromJson(Map<String, dynamic> json) =>
      CoreItemModulesModel(
        moduleAuthor: json['module_author'] == null
            ? null
            : CoreModuleAuthorModel.fromJson(
                json['module_author'] as Map<String, dynamic>),
        moduleDynamic: json['module_dynamic'] == null
            ? null
            : CoreModuleDynamicModel.fromJson(
                json['module_dynamic'] as Map<String, dynamic>),
        moduleStat: json['module_stat'] == null
            ? null
            : CoreModuleStatModel.fromJson(
                json['module_stat'] as Map<String, dynamic>),
        coreModuleTag: json['module_tag'] == null
            ? null
            : CoreModuleTag.fromJson(json['module_tag'] as Map<String, dynamic>),
        coreModuleFold: json['module_fold'] == null
            ? null
            : CoreModuleFold.fromJson(json['module_fold'] as Map<String, dynamic>),
        coreModuleInteraction: json['module_interaction'] == null
            ? null
            : CoreModuleInteraction.fromJson(
                json['module_interaction'] as Map<String, dynamic>),
        coreModuleDispute: json['module_dispute'] == null
            ? null
            : CoreModuleDispute.fromJson(
                json['module_dispute'] as Map<String, dynamic>),
      );
}

class CoreModuleDispute {
  String? title;
  String? coreDesc;
  String? jumpUrl;

  CoreModuleDispute({this.title, this.coreDesc, this.jumpUrl});

  factory CoreModuleDispute.fromJson(Map<String, dynamic> json) => CoreModuleDispute(
        title: json['title'] as String?,
        coreDesc: json['CoreDesc'] as String?,
        jumpUrl: json['jump_url'] as String?,
      );
}

class CoreModuleInteraction {
  List<CoreModuleInteractionItem>? items;

  CoreModuleInteraction({this.items});

  factory CoreModuleInteraction.fromJson(Map<String, dynamic> json) =>
      CoreModuleInteraction(
        items: (json['items'] as List<dynamic>?)
            ?.map((e) =>
                CoreModuleInteractionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreModuleInteractionItem {
  int? type;
  CoreDynamicDescModel? coreDesc;

  CoreModuleInteractionItem({this.type, this.coreDesc});

  factory CoreModuleInteractionItem.fromJson(Map<String, dynamic> json) =>
      CoreModuleInteractionItem(
        type: json['type'] as int?,
        coreDesc: json['CoreDesc'] == null
            ? null
            : CoreDynamicDescModel.fromJson(
                json['CoreDesc'] as Map<String, dynamic>),
      );
}

class CoreModuleFold {
  List<String>? ids;
  String? statement;
  List<CoreOwner>? users;

  CoreModuleFold({this.ids, this.statement, this.users});

  factory CoreModuleFold.fromJson(Map<String, dynamic> json) => CoreModuleFold(
        ids: (json['ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
        statement: json['statement'] as String?,
        users: (json['users'] as List<dynamic>?)
            ?.map((e) => CoreOwner.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreOwner {
  int? mid;
  String? name;
  String? face;

  CoreOwner({this.mid, this.name, this.face});

  factory CoreOwner.fromJson(Map<String, dynamic> json) => CoreOwner(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
      );
}

class CoreModuleCollection {
  String? count;
  int? id;
  String? name;
  String? title;

  CoreModuleCollection({this.count, this.id, this.name, this.title});

  factory CoreModuleCollection.fromJson(Map<String, dynamic> json) =>
      CoreModuleCollection(
        count: json['count'] as String?,
        id: json['id'] as int?,
        name: json['name'] as String?,
        title: json['title'] as String?,
      );
}

class CoreModuleTop {
  CoreModuleTopDisplay? display;

  CoreModuleTop({this.display});

  factory CoreModuleTop.fromJson(Map<String, dynamic> json) => CoreModuleTop(
        display: json['display'] == null
            ? null
            : CoreModuleTopDisplay.fromJson(
                json['display'] as Map<String, dynamic>),
      );
}

class CoreModuleTopDisplay {
  CoreModuleTopAlbum? album;

  CoreModuleTopDisplay({this.album});

  factory CoreModuleTopDisplay.fromJson(Map<String, dynamic> json) =>
      CoreModuleTopDisplay(
        album: json['album'] == null
            ? null
            : CoreModuleTopAlbum.fromJson(json['album'] as Map<String, dynamic>),
      );
}

class CoreModuleTopAlbum {
  List<CorePic>? pics;

  CoreModuleTopAlbum({this.pics});

  factory CoreModuleTopAlbum.fromJson(Map<String, dynamic> json) => CoreModuleTopAlbum(
        pics: (json['pics'] as List<dynamic>?)
            ?.map((e) => CorePic.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CorePic {
  String? src;
  int? width;
  int? height;

  CorePic({this.src, this.width, this.height});

  factory CorePic.fromJson(Map<String, dynamic> json) => CorePic(
        src: json['src'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}

class CoreModuleBlocked {
  CoreBgImg? coreBgImg;
  int? blockedType;
  CoreButton? coreButton;
  String? title;
  String? hintMessage;
  CoreBgImg? icon;

  CoreModuleBlocked({this.coreBgImg, this.blockedType, this.coreButton, this.title, this.hintMessage, this.icon});

  factory CoreModuleBlocked.fromJson(Map<String, dynamic> json) => CoreModuleBlocked(
        coreBgImg: json['bg_img'] == null
            ? null
            : CoreBgImg.fromJson(json['bg_img'] as Map<String, dynamic>),
        blockedType: json['blocked_type'] as int?,
        coreButton: json['CoreButton'] == null
            ? null
            : CoreButton.fromJson(json['CoreButton'] as Map<String, dynamic>),
        title: json['title'] as String?,
        hintMessage: json['hint_message'] as String?,
        icon: json['icon'] == null
            ? null
            : CoreBgImg.fromJson(json['icon'] as Map<String, dynamic>),
      );
}

class CoreButton {
  String? icon;
  String? jumpUrl;
  String? text;
  CoreJumpStyle? coreJumpStyle;
  CoreCheck? coreCheck;

  CoreButton({this.icon, this.jumpUrl, this.text, this.coreJumpStyle, this.coreCheck});

  factory CoreButton.fromJson(Map<String, dynamic> json) => CoreButton(
        icon: json['icon'] as String?,
        jumpUrl: json['jump_url'] as String?,
        text: json['text'] as String?,
        coreJumpStyle: json['jump_style'] == null
            ? null
            : CoreJumpStyle.fromJson(json['jump_style'] as Map<String, dynamic>),
        coreCheck: json['CoreCheck'] == null
            ? null
            : CoreCheck.fromJson(json['CoreCheck'] as Map<String, dynamic>),
      );
}

class CoreCheck {
  String? text;

  CoreCheck({this.text});

  factory CoreCheck.fromJson(Map<String, dynamic> json) => CoreCheck(
        text: json['text'] as String?,
      );
}

class CoreBgImg {
  String? imgDark;
  String? imgDay;

  CoreBgImg({this.imgDark, this.imgDay});

  factory CoreBgImg.fromJson(Map<String, dynamic> json) => CoreBgImg(
        imgDark: json['img_dark'] as String?,
        imgDay: json['img_day'] as String?,
      );
}

class CoreJumpStyle {
  String? text;

  CoreJumpStyle({this.text});

  factory CoreJumpStyle.fromJson(Map<String, dynamic> json) => CoreJumpStyle(
        text: json['text'] as String?,
      );
}

class CoreModuleAuthorModel {
  int? mid;
  String? name;
  String? face;
  String? pubAction;
  String? pubTime;
  int? pubTs;
  String? type;
  CoreDecorate? coreDecorate;
  bool? isTop;
  String? badgeText;
  CoreBaseOfficialVerify? officialVerify;
  CorePendant? corePendant;

  CoreModuleAuthorModel({
    this.mid,
    this.name,
    this.face,
    this.pubAction,
    this.pubTime,
    this.pubTs,
    this.type,
    this.coreDecorate,
    this.isTop,
    this.badgeText,
    this.officialVerify,
    this.corePendant,
  });

  factory CoreModuleAuthorModel.fromJson(Map<String, dynamic> json) =>
      CoreModuleAuthorModel(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        pubAction: json['pub_action'] as String?,
        pubTime: json['pub_time'] as String?,
        pubTs: json['pub_ts'] as int?,
        type: json['type'] as String?,
        coreDecorate: json['CoreDecorate'] == null
            ? null
            : CoreDecorate.fromJson(json['CoreDecorate'] as Map<String, dynamic>),
        isTop: json['is_top'] as bool?,
        badgeText: json['icon_badge']?['text'] as String?,
        officialVerify: json['official'] == null
            ? null
            : CoreBaseOfficialVerify.fromJson(
                json['official'] as Map<String, dynamic>),
        corePendant: json['CorePendant'] == null
            ? null
            : CorePendant.fromJson(json['CorePendant'] as Map<String, dynamic>),
      );
}

class CorePendant {
  String? image;

  CorePendant({this.image});

  factory CorePendant.fromJson(Map<String, dynamic> json) => CorePendant(
        image: json['image'] as String?,
      );
}

class CoreDecorate {
  String? cardUrl;
  CoreFan? coreFan;

  CoreDecorate({this.cardUrl, this.coreFan});

  factory CoreDecorate.fromJson(Map<String, dynamic> json) => CoreDecorate(
        cardUrl: json['card_url'] as String?,
        coreFan: json['CoreFan'] == null
            ? null
            : CoreFan.fromJson(json['CoreFan'] as Map<String, dynamic>),
      );
}

class CoreFan {
  String? color;
  String? numStr;

  CoreFan({this.color, this.numStr});

  factory CoreFan.fromJson(Map<String, dynamic> json) => CoreFan(
        color: json['color'] as String?,
        numStr: json['num_str'] as String?,
      );
}

class CoreModuleDynamicModel {
  CoreDynamicAddModel? additional;
  CoreDynamicDescModel? coreDesc;
  CoreDynamicMajorModel? major;
  CoreDynamicTopicModel? topic;

  CoreModuleDynamicModel({
    this.additional,
    this.coreDesc,
    this.major,
    this.topic,
  });

  factory CoreModuleDynamicModel.fromJson(Map<String, dynamic> json) =>
      CoreModuleDynamicModel(
        additional: json['additional'] == null
            ? null
            : CoreDynamicAddModel.fromJson(
                json['additional'] as Map<String, dynamic>),
        coreDesc: json['CoreDesc'] == null
            ? null
            : CoreDynamicDescModel.fromJson(
                json['CoreDesc'] as Map<String, dynamic>),
        major: json['major'] == null
            ? null
            : CoreDynamicMajorModel.fromJson(
                json['major'] as Map<String, dynamic>),
        topic: json['topic'] == null
            ? null
            : CoreDynamicTopicModel.fromJson(
                json['topic'] as Map<String, dynamic>),
      );
}

class CoreDynamicAddModel {
  String? type;
  CoreVote? coreVote;
  CoreUgc? coreUgc;
  CoreReserve? coreReserve;
  CoreGood? goods;
  CoreUpowerLottery? coreUpowerLottery;
  CoreAddCommon? coreCommon;
  CoreAddMatch? match;

  CoreDynamicAddModel({
    this.type,
    this.coreVote,
    this.coreUgc,
    this.coreReserve,
    this.goods,
    this.coreUpowerLottery,
    this.coreCommon,
    this.match,
  });

  factory CoreDynamicAddModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicAddModel(
        type: json['type'] as String?,
        coreVote: json['CoreVote'] == null
            ? null
            : CoreVote.fromJson(json['CoreVote'] as Map<String, dynamic>),
        coreUgc: json['CoreUgc'] == null
            ? null
            : CoreUgc.fromJson(json['CoreUgc'] as Map<String, dynamic>),
        coreReserve: json['CoreReserve'] == null
            ? null
            : CoreReserve.fromJson(json['CoreReserve'] as Map<String, dynamic>),
        goods: json['goods'] == null
            ? null
            : CoreGood.fromJson(json['goods'] as Map<String, dynamic>),
        coreUpowerLottery: json['upower_lottery'] == null
            ? null
            : CoreUpowerLottery.fromJson(
                json['upower_lottery'] as Map<String, dynamic>),
        coreCommon: json['CoreCommon'] == null
            ? null
            : CoreAddCommon.fromJson(json['CoreCommon'] as Map<String, dynamic>),
        match: json['match'] == null
            ? null
            : CoreAddMatch.fromJson(json['match'] as Map<String, dynamic>),
      );
}

class CoreAddMatch {
  CoreButton? coreButton;
  String? jumpUrl;
  CoreMatchInfo? coreMatchInfo;

  CoreAddMatch({this.coreButton, this.jumpUrl, this.coreMatchInfo});

  factory CoreAddMatch.fromJson(Map<String, dynamic> json) => CoreAddMatch(
        coreButton: json['CoreButton'] == null
            ? null
            : CoreButton.fromJson(json['CoreButton'] as Map<String, dynamic>),
        jumpUrl: json['jump_url'] as String?,
        coreMatchInfo: json['match_info'] == null
            ? null
            : CoreMatchInfo.fromJson(json['match_info'] as Map<String, dynamic>),
      );
}

class CoreMatchInfo {
  String? centerBottom;
  List? centerTop;
  CoreTTeam? leftTeam;
  CoreTTeam? rightTeam;
  dynamic subTitle;
  String? title;

  CoreMatchInfo({
    this.centerBottom,
    this.centerTop,
    this.leftTeam,
    this.rightTeam,
    this.subTitle,
    this.title,
  });

  factory CoreMatchInfo.fromJson(Map<String, dynamic> json) => CoreMatchInfo(
        centerBottom: json['center_bottom'] as String?,
        centerTop: json['center_top'] as List?,
        leftTeam: json['left_team'] == null
            ? null
            : CoreTTeam.fromJson(json['left_team'] as Map<String, dynamic>),
        rightTeam: json['right_team'] == null
            ? null
            : CoreTTeam.fromJson(json['right_team'] as Map<String, dynamic>),
        subTitle: json['sub_title'],
        title: json['title'] as String?,
      );
}

class CoreTTeam {
  String? name;
  String? corePic;

  CoreTTeam({this.name, this.corePic});

  factory CoreTTeam.fromJson(Map<String, dynamic> json) => CoreTTeam(
        name: json['name'] as String?,
        corePic: json['CorePic'] as String?,
      );
}

class CoreAddCommon {
  CoreButton? coreButton;
  String? cover;
  String? desc1;
  String? desc2;
  String? jumpUrl;
  String? title;

  CoreAddCommon({
    this.coreButton,
    this.cover,
    this.desc1,
    this.desc2,
    this.jumpUrl,
    this.title,
  });

  factory CoreAddCommon.fromJson(Map<String, dynamic> json) => CoreAddCommon(
        coreButton: json['CoreButton'] == null
            ? null
            : CoreButton.fromJson(json['CoreButton'] as Map<String, dynamic>),
        cover: json['cover'] as String?,
        desc1: json['desc1'] as String?,
        desc2: json['desc2'] as String?,
        jumpUrl: json['jump_url'] as String?,
        title: json['title'] as String?,
      );
}

class CoreUpowerLottery {
  CoreButton? coreButton;
  CoreDesc? coreDesc;
  CoreHint? coreHint;
  String? jumpUrl;
  String? title;

  CoreUpowerLottery({
    this.coreButton,
    this.coreDesc,
    this.coreHint,
    this.jumpUrl,
    this.title,
  });

  factory CoreUpowerLottery.fromJson(Map<String, dynamic> json) => CoreUpowerLottery(
        coreButton: json['CoreButton'] == null
            ? null
            : CoreButton.fromJson(json['CoreButton'] as Map<String, dynamic>),
        coreDesc: json['CoreDesc'] == null
            ? null
            : CoreDesc.fromJson(json['CoreDesc'] as Map<String, dynamic>),
        coreHint: json['CoreHint'] == null
            ? null
            : CoreHint.fromJson(json['CoreHint'] as Map<String, dynamic>),
        jumpUrl: json['jump_url'] as String?,
        title: json['title'] as String?,
      );
}

class CoreHint {
  String? text;

  CoreHint({this.text});

  factory CoreHint.fromJson(Map<String, dynamic> json) => CoreHint(
        text: json['text'] as String?,
      );
}

class CoreVote {
  int? joinNum;
  int? voteId;
  String? title;

  CoreVote({this.joinNum, this.voteId, this.title});

  factory CoreVote.fromJson(Map<String, dynamic> json) => CoreVote(
        joinNum: json['join_num'] as int?,
        voteId: json['vote_id'] as int?,
        title: json['title'] as String? ?? json['CoreDesc'] as String?,
      );
}

class CoreUgc {
  String? cover;
  String? descSecond;
  String? jumpUrl;
  String? title;

  CoreUgc({this.cover, this.descSecond, this.jumpUrl, this.title});

  factory CoreUgc.fromJson(Map<String, dynamic> json) => CoreUgc(
        cover: json['cover'] as String?,
        descSecond: json['desc_second'] as String?,
        jumpUrl: json['jump_url'] as String?,
        title: json['title'] as String?,
      );
}

class CoreReserve {
  CoreReserveBtn? coreButton;
  CoreDesc? desc1;
  CoreDesc? desc2;
  CoreDesc? desc3;
  int? reserveTotal;
  int? rid;
  int? state;
  String? title;

  CoreReserve({
    this.coreButton,
    this.desc1,
    this.desc2,
    this.desc3,
    this.reserveTotal,
    this.rid,
    this.state,
    this.title,
  });

  factory CoreReserve.fromJson(Map<String, dynamic> json) => CoreReserve(
        coreButton: json['CoreButton'] == null
            ? null
            : CoreReserveBtn.fromJson(json['CoreButton'] as Map<String, dynamic>),
        desc1: json['desc1'] == null
            ? null
            : CoreDesc.fromJson(json['desc1'] as Map<String, dynamic>),
        desc2: json['desc2'] == null
            ? null
            : CoreDesc.fromJson(json['desc2'] as Map<String, dynamic>),
        desc3: json['desc3'] == null
            ? null
            : CoreDesc.fromJson(json['desc3'] as Map<String, dynamic>),
        reserveTotal: json['reserve_total'] as int?,
        rid: json['rid'] as int?,
        state: json['state'] as int?,
        title: json['title'] as String?,
      );
}

class CoreReserveBtn {
  int? status;
  int? type;
  String? checkText;
  String? uncheckText;
  int? disable;
  String? jumpText;
  String? jumpUrl;

  CoreReserveBtn({
    this.status,
    this.type,
    this.checkText,
    this.uncheckText,
    this.disable,
    this.jumpText,
    this.jumpUrl,
  });

  factory CoreReserveBtn.fromJson(Map<String, dynamic> json) => CoreReserveBtn(
        status: json['status'] as int?,
        type: json['type'] as int?,
        checkText: json['CoreCheck']?['text'] as String? ?? '已预约',
        uncheckText: json['uncheck']?['text'] as String? ?? '预约',
        disable: json['uncheck']?['disable'] as int?,
        jumpText: json['jump_style']?['text'] as String?,
        jumpUrl: json['jump_url'] as String?,
      );
}

class CoreDesc {
  String? text;
  String? jumpUrl;

  CoreDesc({this.text, this.jumpUrl});

  factory CoreDesc.fromJson(Map<String, dynamic> json) => CoreDesc(
        text: json['text'] as String?,
        jumpUrl: json['jump_url'] as String?,
      );
}

class CoreGood {
  List<CoreGoodItem>? items;

  CoreGood({this.items});

  factory CoreGood.fromJson(Map<String, dynamic> json) => CoreGood(
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => CoreGoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreGoodItem {
  String? cover;
  String? jumpDesc;
  String? jumpUrl;
  String? name;
  String? price;

  CoreGoodItem({
    this.cover,
    this.jumpDesc,
    this.jumpUrl,
    this.name,
    this.price,
  });

  factory CoreGoodItem.fromJson(Map<String, dynamic> json) => CoreGoodItem(
        cover: json['cover'] as String?,
        jumpDesc: json['jump_desc'] as String?,
        jumpUrl: json['jump_url'] as String?,
        name: json['name'] as String?,
        price: json['price'] as String?,
      );
}

class CoreDynamicDescModel {
  List<CoreRichTextNodeItem>? richTextNodes;
  String? text;

  CoreDynamicDescModel({this.richTextNodes, this.text});

  factory CoreDynamicDescModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicDescModel(
        richTextNodes: (json['rich_text_nodes'] as List<dynamic>?)
            ?.map((e) =>
                CoreRichTextNodeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        text: json['text'] as String?,
      );
}

class CoreDynamicMajorModel {
  CoreDynamicArchiveModel? coreArchive;
  CoreDynamicArchiveModel? coreUgcSeason;
  CoreDynamicOpusModel? opus;
  CoreDynamicArchiveModel? pgc;
  CoreDynamicLiveModel? coreLiveRcmd;
  CoreDynamicLive2Model? coreLive;
  CoreDynamicNoneModel? none;
  String? type;
  CoreDynamicArchiveModel? courses;
  CoreCommon? coreCommon;
  CoreCommon? upowerCommon;
  CoreMusic? coreMusic;
  CoreModuleBlocked? blocked;
  CoreMedialist? coreMedialist;
  CoreSubscriptionNew? coreSubscriptionNew;

  CoreDynamicMajorModel({
    this.coreArchive,
    this.coreUgcSeason,
    this.opus,
    this.pgc,
    this.coreLiveRcmd,
    this.coreLive,
    this.none,
    this.type,
    this.courses,
    this.coreCommon,
    this.upowerCommon,
    this.coreMusic,
    this.blocked,
    this.coreMedialist,
    this.coreSubscriptionNew,
  });

  factory CoreDynamicMajorModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicMajorModel(
        coreArchive: json['CoreArchive'] == null
            ? null
            : CoreDynamicArchiveModel.fromJson(
                json['CoreArchive'] as Map<String, dynamic>),
        coreUgcSeason: json['ugc_season'] == null
            ? null
            : CoreDynamicArchiveModel.fromJson(
                json['ugc_season'] as Map<String, dynamic>),
        opus: json['opus'] == null
            ? null
            : CoreDynamicOpusModel.fromJson(
                json['opus'] as Map<String, dynamic>),
        pgc: json['pgc'] == null
            ? null
            : CoreDynamicArchiveModel.fromJson(
                json['pgc'] as Map<String, dynamic>),
        coreLiveRcmd: json['live_rcmd'] == null
            ? null
            : CoreDynamicLiveModel.fromJson(
                json['live_rcmd'] as Map<String, dynamic>),
        coreLive: json['CoreLive'] == null
            ? null
            : CoreDynamicLive2Model.fromJson(
                json['CoreLive'] as Map<String, dynamic>),
        none: json['none'] == null
            ? null
            : CoreDynamicNoneModel.fromJson(
                json['none'] as Map<String, dynamic>),
        type: json['type'] as String?,
        courses: json['courses'] == null
            ? null
            : CoreDynamicArchiveModel.fromJson(
                json['courses'] as Map<String, dynamic>),
        coreCommon: json['CoreCommon'] == null
            ? null
            : CoreCommon.fromJson(json['CoreCommon'] as Map<String, dynamic>),
        upowerCommon: json['upower_common'] == null
            ? null
            : CoreCommon.fromJson(json['upower_common'] as Map<String, dynamic>),
        coreMusic: json['CoreMusic'] == null
            ? null
            : CoreMusic.fromJson(json['CoreMusic'] as Map<String, dynamic>),
        blocked: json['blocked'] == null
            ? null
            : CoreModuleBlocked.fromJson(
                json['blocked'] as Map<String, dynamic>),
        coreMedialist: json['CoreMedialist'] == null
            ? null
            : CoreMedialist.fromJson(json['CoreMedialist'] as Map<String, dynamic>),
        coreSubscriptionNew: json['subscription_new'] == null
            ? null
            : CoreSubscriptionNew.fromJson(
                json['subscription_new'] as Map<String, dynamic>),
      );
}

class CoreMusic {
  int? id;
  String? cover;
  String? title;
  String? label;

  CoreMusic({this.id, this.cover, this.title, this.label});

  factory CoreMusic.fromJson(Map<String, dynamic> json) => CoreMusic(
        id: json['id'] as int?,
        cover: json['cover'] as String?,
        title: json['title'] as String?,
        label: json['label'] as String?,
      );
}

class CoreMedialist {
  dynamic id;
  String? cover;
  String? title;
  String? subTitle;
  String? jumpUrl;
  CoreBadge? badge;

  CoreMedialist({this.id, this.cover, this.title, this.subTitle, this.jumpUrl, this.badge});

  factory CoreMedialist.fromJson(Map<String, dynamic> json) => CoreMedialist(
        id: json['id'],
        cover: json['cover'] as String?,
        title: json['title'] as String?,
        subTitle: json['sub_title'] as String?,
        jumpUrl: json['jump_url'] as String?,
        badge: json['badge'] == null
            ? null
            : CoreBadge.fromJson(json['badge'] as Map<String, dynamic>),
      );
}

class CoreSubscriptionNew {
  CoreLiveRcmd? coreLiveRcmd;

  CoreSubscriptionNew({this.coreLiveRcmd});

  factory CoreSubscriptionNew.fromJson(Map<String, dynamic> json) =>
      CoreSubscriptionNew(
        coreLiveRcmd: json['live_rcmd'] == null
            ? null
            : CoreLiveRcmd.fromJson(json['live_rcmd'] as Map<String, dynamic>),
      );
}

class CoreLiveRcmd {
  CoreLiveRcmdContent? content;

  CoreLiveRcmd({this.content});

  factory CoreLiveRcmd.fromJson(Map<String, dynamic> json) => CoreLiveRcmd(
        content: json['content'] == null
            ? null
            : CoreLiveRcmdContent.fromJson(json['content'] as Map<String, dynamic>),
      );
}

class CoreLiveRcmdContent {
  CoreLivePlayInfo? coreLivePlayInfo;

  CoreLiveRcmdContent({this.coreLivePlayInfo});

  factory CoreLiveRcmdContent.fromJson(Map<String, dynamic> json) =>
      CoreLiveRcmdContent(
        coreLivePlayInfo: json['live_play_info'] == null
            ? null
            : CoreLivePlayInfo.fromJson(
                json['live_play_info'] as Map<String, dynamic>),
      );
}

class CoreLivePlayInfo {
  int? roomId;
  int? liveStatus;
  String? title;
  String? cover;
  String? areaName;
  CoreWatchedShow? coreWatchedShow;

  CoreLivePlayInfo({
    this.roomId,
    this.liveStatus,
    this.title,
    this.cover,
    this.areaName,
    this.coreWatchedShow,
  });

  factory CoreLivePlayInfo.fromJson(Map<String, dynamic> json) => CoreLivePlayInfo(
        roomId: json['room_id'] as int?,
        liveStatus: json['live_status'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        areaName: json['area_name'] as String?,
        coreWatchedShow: json['watched_show'] == null
            ? null
            : CoreWatchedShow.fromJson(
                json['watched_show'] as Map<String, dynamic>),
      );
}

class CoreDynamicTopicModel {
  int? id;
  String? name;

  CoreDynamicTopicModel({this.id, this.name});

  factory CoreDynamicTopicModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicTopicModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
      );
}

class CoreDynamicArchiveModel {
  int? id;
  int? aid;
  CoreBadge? badge;
  String? bvid;
  String? cover;
  String? durationText;
  String? jumpUrl;
  CoreStat? coreStat;
  String? title;
  int? type;
  int? epid;
  int? seasonId;

  CoreDynamicArchiveModel({
    this.id,
    this.aid,
    this.badge,
    this.bvid,
    this.cover,
    this.durationText,
    this.jumpUrl,
    this.coreStat,
    this.title,
    this.type,
    this.epid,
    this.seasonId,
  });

  factory CoreDynamicArchiveModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicArchiveModel(
        id: json['id'] as int?,
        aid: json['aid'] as int?,
        badge: json['badge'] == null
            ? null
            : CoreBadge.fromJson(json['badge'] as Map<String, dynamic>),
        bvid: json['bvid'] as String?,
        cover: json['cover'] as String?,
        durationText: json['duration_text'] as String?,
        jumpUrl: json['jump_url'] as String?,
        coreStat: json['CoreStat'] == null
            ? null
            : CoreStat.fromJson(json['CoreStat'] as Map<String, dynamic>),
        title: json['title'] as String?,
        type: json['type'] as int?,
        epid: json['epid'] as int?,
        seasonId: json['season_id'] as int?,
      );
}

class CoreStat {
  String? danmu;
  String? play;

  CoreStat({this.danmu, this.play});

  factory CoreStat.fromJson(Map<String, dynamic> json) => CoreStat(
        danmu: json['danmaku'] as String?,
        play: json['play'] as String?,
      );
}

class CoreDynamicOpusModel {
  List<CoreOpusPicModel>? pics;
  CoreSummaryModel? summary;
  String? title;

  CoreDynamicOpusModel({this.pics, this.summary, this.title});

  factory CoreDynamicOpusModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicOpusModel(
        pics: (json['pics'] as List<dynamic>?)
            ?.map((e) => CoreOpusPicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: json['summary'] == null
            ? null
            : CoreSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
        title: json['title'] as String?,
      );
}

class CoreSummaryModel {
  List<CoreRichTextNodeItem>? richTextNodes;
  String? text;

  CoreSummaryModel({this.richTextNodes, this.text});

  factory CoreSummaryModel.fromJson(Map<String, dynamic> json) => CoreSummaryModel(
        richTextNodes: (json['rich_text_nodes'] as List<dynamic>?)
            ?.map((e) =>
                CoreRichTextNodeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        text: json['text'] as String?,
      );
}

class CoreRichTextNodeItem {
  CoreEmoji? coreEmoji;
  String? origText;
  String? text;
  String? type;
  String? rid;
  List<CoreOpusPicModel>? pics;
  String? jumpUrl;

  CoreRichTextNodeItem({
    this.coreEmoji,
    this.origText,
    this.text,
    this.type,
    this.rid,
    this.pics,
    this.jumpUrl,
  });

  factory CoreRichTextNodeItem.fromJson(Map<String, dynamic> json) =>
      CoreRichTextNodeItem(
        coreEmoji: json['CoreEmoji'] == null
            ? null
            : CoreEmoji.fromJson(json['CoreEmoji'] as Map<String, dynamic>),
        origText: json['orig_text'] as String?,
        text: json['text'] as String?,
        type: json['type'] as String?,
        rid: json['rid'] as String?,
        pics: (json['pics'] as List<dynamic>?)
            ?.map((e) => CoreOpusPicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        jumpUrl: json['jump_url'] as String?,
      );
}

class CoreEmoji {
  String? url;
  num? size;

  CoreEmoji({this.url, this.size});

  factory CoreEmoji.fromJson(Map<String, dynamic> json) => CoreEmoji(
        url: (json['webp_url'] as String?) ??
            (json['gif_url'] as String?) ??
            (json['icon_url'] as String?),
        size: json['size'] as num? ?? 1,
      );
}

class CoreDynamicNoneModel {
  String? tips;

  CoreDynamicNoneModel({this.tips});

  factory CoreDynamicNoneModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicNoneModel(
        tips: json['tips'] as String?,
      );
}

sealed class CorePicModel {}

class CoreFilePicModel extends CorePicModel {
  String path;

  CoreFilePicModel({required this.path});
}

class CoreOpusPicModel extends CorePicModel {
  int? width;
  int? height;
  String? src;
  String? url;
  String? liveUrl;
  num? size;

  CoreOpusPicModel({
    this.width,
    this.height,
    this.src,
    this.url,
    this.liveUrl,
    this.size,
  });

  factory CoreOpusPicModel.fromJson(Map<String, dynamic> json) => CoreOpusPicModel(
        width: json['width'] as int?,
        height: json['height'] as int?,
        src: json['src'] as String?,
        url: json['url'] as String?,
        liveUrl: json['live_url'] as String?,
        size: json['size'] as num?,
      );
}

class CoreDynamicLiveModel {
  int? roomId;
  int? liveStatus;
  String? cover;
  String? areaName;
  String? title;
  CoreWatchedShow? coreWatchedShow;

  CoreDynamicLiveModel({
    this.roomId,
    this.liveStatus,
    this.cover,
    this.areaName,
    this.title,
    this.coreWatchedShow,
  });

  factory CoreDynamicLiveModel.fromJson(Map<String, dynamic> json) =>
      CoreDynamicLiveModel(
        roomId: json['room_id'] as int?,
        liveStatus: json['live_status'] as int?,
        cover: json['cover'] as String?,
        areaName: json['area_name'] as String?,
        title: json['title'] as String?,
        coreWatchedShow: json['watched_show'] == null
            ? null
            : CoreWatchedShow.fromJson(
                json['watched_show'] as Map<String, dynamic>),
      );
}

class CoreDynamicLive2Model {
  CoreBadge? badge;
  String? cover;
  String? descFirst;
  int? id;
  int? liveState;
  String? title;

  CoreDynamicLive2Model({
    this.badge,
    this.cover,
    this.descFirst,
    this.id,
    this.liveState,
    this.title,
  });

  factory CoreDynamicLive2Model.fromJson(Map<String, dynamic> json) =>
      CoreDynamicLive2Model(
        badge: json['badge'] == null
            ? null
            : CoreBadge.fromJson(json['badge'] as Map<String, dynamic>),
        cover: json['cover'] as String?,
        descFirst: json['desc_first'] as String?,
        id: json['id'] as int?,
        liveState: json['live_state'] as int?,
        title: json['title'] as String?,
      );
}

class CoreModuleTag {
  String? text;

  CoreModuleTag({this.text});

  factory CoreModuleTag.fromJson(Map<String, dynamic> json) => CoreModuleTag(
        text: json['text'] as String?,
      );
}

class CoreModuleStatModel {
  CoreDynamicStat? comment;
  CoreDynamicStat? forward;
  CoreDynamicStat? like;
  CoreDynamicStat? favorite;

  CoreModuleStatModel({
    this.comment,
    this.forward,
    this.like,
    this.favorite,
  });

  factory CoreModuleStatModel.fromJson(Map<String, dynamic> json) =>
      CoreModuleStatModel(
        comment: json['comment'] == null
            ? null
            : CoreDynamicStat.fromJson(json['comment'] as Map<String, dynamic>),
        forward: json['forward'] == null
            ? null
            : CoreDynamicStat.fromJson(json['forward'] as Map<String, dynamic>),
        like: json['like'] == null
            ? null
            : CoreDynamicStat.fromJson(json['like'] as Map<String, dynamic>),
        favorite: json['favorite'] == null
            ? null
            : CoreDynamicStat.fromJson(json['favorite'] as Map<String, dynamic>),
      );
}

class CoreDynamicStat {
  int? count;
  bool? status;

  CoreDynamicStat({this.count, this.status});

  factory CoreDynamicStat.fromJson(Map<String, dynamic> json) => CoreDynamicStat(
        count: json['count'] as int?,
        status: json['status'] as bool?,
      );
}

class CoreCommon {
  String? cover;
  String? title;
  String? coreDesc;
  String? jumpUrl;

  CoreCommon({this.cover, this.title, this.coreDesc, this.jumpUrl});

  factory CoreCommon.fromJson(Map<String, dynamic> json) => CoreCommon(
        cover: json['cover'] as String?,
        title: json['title'] as String?,
        coreDesc: json['CoreDesc'] as String?,
        jumpUrl: json['jump_url'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Member tag
// ---------------------------------------------------------------------------

class CoreMemberTagItemModel {
  int? count;
  String? name;
  int? tagid;
  String? tip;

  CoreMemberTagItemModel({this.count, this.name, this.tagid, this.tip});

  CoreMemberTagItemModel.fromCreate(({int tagid, String tagName}) res, {this.count = 0})
      : tagid = res.tagid,
        name = res.tagName;

  factory CoreMemberTagItemModel.fromJson(Map<String, dynamic> json) =>
      CoreMemberTagItemModel(
        count: json['count'] as int?,
        name: json['name'] as String?,
        tagid: json['tagid'] as int?,
        tip: json['tip'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Space opus
// ---------------------------------------------------------------------------

class CoreSpaceOpusData {
  bool? hasMore;
  List<CoreSpaceOpusItemModel>? items;
  String? offset;

  CoreSpaceOpusData({this.hasMore, this.items, this.offset});

  factory CoreSpaceOpusData.fromJson(Map<String, dynamic> json) => CoreSpaceOpusData(
        hasMore: json['has_more'] as bool?,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) =>
                CoreSpaceOpusItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        offset: json['offset'] as String?,
      );
}

class CoreSpaceOpusItemModel {
  String? content;
  String? opusId;
  CoreOpusStat? coreStat;
  CoreOpusCover? cover;

  CoreSpaceOpusItemModel({this.content, this.opusId, this.coreStat, this.cover});

  factory CoreSpaceOpusItemModel.fromJson(Map<String, dynamic> json) =>
      CoreSpaceOpusItemModel(
        content: json['content'] as String?,
        opusId: json['opus_id'] as String?,
        coreStat: json['CoreStat'] == null
            ? null
            : CoreOpusStat.fromJson(json['CoreStat'] as Map<String, dynamic>),
        cover: json['cover'] == null
            ? null
            : CoreOpusCover.fromJson(json['cover'] as Map<String, dynamic>),
      );
}

class CoreOpusStat {
  int? view;
  int? like;

  CoreOpusStat({this.view, this.like});

  factory CoreOpusStat.fromJson(Map<String, dynamic> json) => CoreOpusStat(
        view: json['view'] as int?,
        like: json['like'] as int?,
      );
}

class CoreOpusCover {
  String? url;
  int? width;
  int? height;

  CoreOpusCover({this.url, this.width, this.height});

  factory CoreOpusCover.fromJson(Map<String, dynamic> json) => CoreOpusCover(
        url: json['url'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Upower rank
// ---------------------------------------------------------------------------

class CoreUpowerRankData {
  List<CoreUpowerRankInfo>? rankInfo;
  int? privilegeType;
  List<int>? tabs;
  List<CoreLevelInfo>? coreLevelInfo;

  CoreUpowerRankData({
    this.rankInfo,
    this.privilegeType,
    this.tabs,
    this.coreLevelInfo,
  });

  factory CoreUpowerRankData.fromJson(Map<String, dynamic> json) =>
      CoreUpowerRankData(
        rankInfo: (json['rank_info'] as List<dynamic>?)
            ?.map((e) =>
                CoreUpowerRankInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
        privilegeType: json['privilege_type'] as int?,
        tabs: (json['tabs'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
        coreLevelInfo: (json['level_info'] as List<dynamic>?)
            ?.map((e) => CoreLevelInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreUpowerRankInfo {
  int? mid;
  String? nickname;
  String? avatar;
  int? day;

  CoreUpowerRankInfo({this.mid, this.nickname, this.avatar, this.day});

  factory CoreUpowerRankInfo.fromJson(Map<String, dynamic> json) =>
      CoreUpowerRankInfo(
        mid: json['mid'] as int?,
        nickname: json['nickname'] as String?,
        avatar: json['avatar'] as String?,
        day: json['day'] as int?,
      );
}

class CoreLevelInfo {
  int? privilegeType;
  String? name;
  int? memberTotal;

  CoreLevelInfo({this.privilegeType, this.name, this.memberTotal});

  factory CoreLevelInfo.fromJson(Map<String, dynamic> json) => CoreLevelInfo(
        privilegeType: json['privilege_type'] as int?,
        name: json['name'] as String?,
        memberTotal: json['member_total'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Coin / Like CoreArchive
// ---------------------------------------------------------------------------

class CoreCoinLikeArcData {
  int? count;
  List<CoreCoinLikeArcItem>? item;

  CoreCoinLikeArcData({this.count, this.item});

  factory CoreCoinLikeArcData.fromJson(Map<String, dynamic> json) =>
      CoreCoinLikeArcData(
        count: json['count'] as int?,
        item: (json['item'] as List<dynamic>?)
            ?.map((e) =>
                CoreCoinLikeArcItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreCoinLikeArcItem {
  String? title;
  String? cover;
  String? uri;
  String? param;
  int? duration;
  bool? isSteins;
  bool? isCooperation;
  bool? isPgc;
  int? play;
  int? danmaku;
  int? ctime;

  CoreCoinLikeArcItem({
    this.title,
    this.cover,
    this.uri,
    this.param,
    this.duration,
    this.isSteins,
    this.isCooperation,
    this.isPgc,
    this.play,
    this.danmaku,
    this.ctime,
  });

  factory CoreCoinLikeArcItem.fromJson(Map<String, dynamic> json) =>
      CoreCoinLikeArcItem(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        uri: json['uri'] as String?,
        param: json['param'] as String?,
        duration: json['duration'] as int?,
        isSteins: json['is_steins'] as bool?,
        isCooperation: json['is_cooperation'] as bool?,
        isPgc: json['is_pgc'] as bool?,
        play: json['play'] as int?,
        danmaku: json['danmaku'] as int?,
        ctime: json['ctime'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Space shop
// ---------------------------------------------------------------------------

class CoreSpaceShopData {
  List<CoreSpaceShopItem>? data;
  bool? showMoreTab;
  String? clickUrl;
  String? showMoreDesc;
  bool? haveNextPage;

  CoreSpaceShopData({
    this.data,
    this.showMoreTab,
    this.clickUrl,
    this.showMoreDesc,
    this.haveNextPage,
  });

  factory CoreSpaceShopData.fromJson(Map<String, dynamic> json) => CoreSpaceShopData(
        data: (json['data'] as List<dynamic>?)
            ?.map((e) =>
                CoreSpaceShopItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        showMoreTab: json['showMoreTab'] as bool?,
        clickUrl: json['clickUrl'] as String?,
        showMoreDesc: json['showMoreDesc'] as String?,
        haveNextPage: json['haveNextPage'] as bool?,
      );
}

class CoreSpaceShopItem {
  String? title;
  String? cardUrl;
  String? coverUrl;

  CoreSpaceShopItem({this.title, this.cardUrl, this.coverUrl});

  factory CoreSpaceShopItem.fromJson(Map<String, dynamic> json) => CoreSpaceShopItem(
        title: json['title'] as String?,
        cardUrl: json['cardUrl'] as String?,
        coverUrl: json['cover']?['url'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Member CoreGuard
// ---------------------------------------------------------------------------

class CoreMemberGuardData {
  List<CoreGuardItem> guardTopList;
  int? hasMore;

  CoreMemberGuardData({required this.guardTopList, this.hasMore});

  factory CoreMemberGuardData.fromJson(Map<String, dynamic> json) =>
      CoreMemberGuardData(
        guardTopList: (json['guard_top_list'] as List<dynamic>)
            .map((e) => CoreGuardItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: json['has_more'] as int?,
      );
}

class CoreGuardItem {
  int uid;
  String username;
  String face;
  int guardLevel;

  CoreGuardItem({
    required this.uid,
    required this.username,
    required this.face,
    required this.guardLevel,
  });

  factory CoreGuardItem.fromJson(Map<String, dynamic> json) => CoreGuardItem(
        uid: json['uid'] as int,
        username: json['username'] as String,
        face: json['face'] as String,
        guardLevel: json['guard_level'] as int,
      );
}

// ---------------------------------------------------------------------------
// CoreArticle content model (shared with dynamics)
// ---------------------------------------------------------------------------

class CoreArticleContentModel {
  String? text;
  String? type;
  String? url;
  int? width;
  int? height;

  CoreArticleContentModel({this.text, this.type, this.url, this.width, this.height});

  factory CoreArticleContentModel.fromJson(Map<String, dynamic> json) =>
      CoreArticleContentModel(
        text: json['text'] as String?,
        type: json['type'] as String?,
        url: json['url'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}