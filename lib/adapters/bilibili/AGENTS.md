# AGENTS.md: lib/adapters/bilibili

Child of root AGENTS.md. Adapter-specific facts only; root rules (lints, CI, dependency forks, package:skf imports) apply.

## Overview

Largest subtree of the repo (~1,025 non-generated Dart files): full B站 client. 24 repositories, all UI pages, HTTP/2 + gRPC networking, media_kit player, Core↔adapter converters.

## Layout (14 subdirs)

- root (2): bili_adapter.dart (38ln thin AppAdapter), bridge.dart (319ln, single entry point)
- repository/ 24: Bili*Repository for all core interfaces
- pages/ 441 (114 page dirs): all B站 UI (~165 view.dart, 138 controllers)
- http/ 27: Request singleton + 25 endpoint files + retry_interceptor
- grpc/ 8 hand-written (audio/dm/dyn/grpc_req/im/reply/space/url) + 99 generated .pb* (analysis-excluded)
- utils/ 32: model_converters.dart (1594ln) + accounts/ (AccountManager) + extension/
- models/ 87: legacy PiliPlus-era models (@HiveType + .g.dart codegen)
- models_new/ 366: plain fromJson DTOs, <feature>/<endpoint>/data|result|item.dart, 80 subdirs
- player/ 3: bili_player_factory, bili_reporter, media_ids
- services/ 9: account provider, download/, audio, logger, service_locator
- plugin/ 27: pl_player/ = media_kit player UI layer
- common/ 7, router/ 1, account/ 1, tcp/ 1

## bridge.dart (entry point, all static)

- initHive(): registers 7 Hive TypeAdapters (Owner, UserInfoData, LevelInfo, BiliCookieJar, LoginAccount, AccountType, RuleFilter). MUST run before GStorage.init() (root gotcha).
- register(): idempotent. Get.lazyPut for all 24 Bili*Repository (bound to core interfaces), PlaybackReporter, AccountProvider, PlayerFactory, AccountService, DownloadService. PluginRegistry + LocalFilePlugin. setupServiceLocator(). _initHttp(). Search special-case: lazyPut<BiliSearchRepository>, then lazyPut<SearchRepository>(() => Get.find<BiliSearchRepository>()).
- registerRoutes(): ~60 GetPage, feature-gated by AppFeatures.* flags at registration time.

## HTTP stack

- Request (http/init.dart, 360ln): Dio singleton, dio_http2_adapter Http2Adapter + ConnectionManager (fallback IOHttpClientAdapter), custom _responseDecoder (brotli+gzip; Http2Adapter does not auto-decompress). Interceptors: RetryInterceptor (if Pref.retryCount!=0) → LogInterceptor (debug) → AccountManager. Errors: get/post/downloadFile swallow DioException → Response(data: {'message': AccountManager.dioError(e)}).
- AccountManager (utils/accounts/account_manager/account_mgr.dart): vendored fork of dio_cookie_manager. Per-request account cookie/header/sign injection (AppSign.appSign), referer, gRPC headers, persisted Hive cookie jar (BiliCookieJarAdapter).

## Repository pattern (bili_video_repository.dart is canonical)

- Each repo: _mapState<A,T>(LoadingState<A> state, mapper) maps Loading/Success/Error → core LoadingState. Each method calls XxxHttp.method(), then converts adapter→core via static _toCore* helpers. Repos NEVER call dio directly.

## Pages pattern

- One dir per page → view.dart + controller.dart (+ optional widgets/, models/, child/).
- Shared infra pages/common/: common_controller.dart (CommonController<R,T> extends GetxController with ScrollOrRefreshMixin), common_page.dart (CommonPageState), common_intro_controller, common_whisper_controller, reply_controller, home_tab_helper, dyn/.
- Controllers: `late final Map args;` from GetPage arguments. Get.find<Repo>() (449 sites), Get.put (139), Obx (416).
- Pagination: onRefresh()→queryData(true), onLoadMore()→queryData(false), hasMore/pageInfo?.hasMore guards, cursor _offset. Custom scroll physics (NO EasyRefresh).

## model_converters.dart (utils/model_converters.dart, 1594ln)

- `abstract final class ModelConverters`: ~40 public statics + ~60 private _toCore* helpers. Pattern: build Map<String,dynamic> from Core fields → adapter fromJson() (JSON round-trip without core toJson).
- Covers: HotVideoItem, BgmRecommend, SpaceArchiveItem (5 variants), MemberHome bridge, SubDetailItem, Rcmd (3 variants), Dimension, Dynamics vote/rich-text/module (largest family, bidirectional), SponsorBlock, MemberTags, Follow, MedalWall, SpaceCard/Live/Reservation, SuperChat, Article, History.

## models/ vs models_new/

- models/ = shared/cross-feature + Hive-persisted types. model_owner, model_avatar, model_video, model_hot_video_item, model_rec_video_item, pgc_lcf have @HiveType + .g.dart. common/ has enums: video_type, audio_quality, subtitle_pref_type, account_type.
- models_new/ = endpoint-specific plain DTOs, no Hive. Both live and both imported by repos + model_converters. 'new' is historical naming (both added at repo inception).

## Dead code (do not use)

- router/app_pages.dart: Routes.getPages. Ungated duplicate of bridge routes, ZERO references.
- account/bili_account_provider.dart: legacy GetxService class, same name as live services/bili_account_provider.dart, ZERO references.

## Anti-patterns

- `as dynamic` is BANNED (SPES-014); use ModelConverters. Remaining casts are compile-visible type-identity casts ((m.stat as RcmdStat?), (dio.httpClientAdapter as Http2Adapter), .cast<String,dynamic>()).
- Do NOT edit generated: lib/adapters/bilibili/grpc/** .pb.dart and models/*.g.dart.
- Fat controllers: pages/video/controller.dart ~1,650ln. Keep new logic out of controllers; prefer CommonController + repos.
- Dual model trees overlap in domain. Prefer models_new for new endpoint DTOs; models/ only for shared/Hive types.
- http/error_msg.dart has mojibake encoding issue in Chinese strings. Fix encoding if touched.

## Where to look

| Task | Location |
|---|---|
| Add API endpoint | http/<domain>.dart + repository/bili_<domain>_repository.dart |
| New page | pages/<page>/{view,controller}.dart + register in bridge.registerRoutes() |
| Core↔adapter type conversion | utils/model_converters.dart |
| Player behavior | player/ + plugin/pl_player/ (media_kit wrapper) |
| gRPC API | grpc/ (hand-written wrappers only) |
