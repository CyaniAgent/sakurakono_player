# AGENTS.md — OttoHub Adapter

Child of root AGENTS.md. Global rules, CI, launch configs live there. This file covers `lib/adapters/ottohub/` only.

## Overview

Thin DI overlay adapter (28 files): swaps in OttoHub repositories/player/account under the SAME bilibili UI. No pages of its own.

## Structure

| Subdir | Files | Role |
|---|---|---|
| root | bridge.dart | OttoAdapter implements AppAdapter (the only adapter class) |
| repository/ | 24 | otto_*_repository.dart, one per core interface |
| player/ | 2 | otto_player_factory.dart + otto_reporter.dart |
| services/ | 1 | otto_account_provider.dart |

- NO `utils/` dir exists here — do not add one; `Get.find` services live in services/.

## DI pattern (bridge.dart)

- `registerDependencies()`: creates ONE `OttohubClient()` (vendored SDK), then chains `Get.lazyPut<CoreRepo>(() => OttoXxxRepository(client))`; stubs use `OttoXxxRepository.new`. Registers AccountProvider→OttoAccountProvider, PlaybackReporter→OttoReporter, PlayerFactory→OttoPlayerFactory, plus private `_StubDownloadService` (extends bilibili DownloadService to prevent `Get.find<DownloadService>()` crashes).
- Repository coverage:
  - 13 REAL (modern SDK API): Video, Auth, Danmaku, Follow, Black, User, Member, Dynamics, Reply, Fav, Msg, Im, Fan.
  - 2 PARTIAL (client-backed, partially implemented): Search (searchAll/ab2c real, 5 methods stub), Space (searchArchive real, opusSpaceFlow stub).
  - 9 STUBS (every method returns `Error('not_implemented')`): Audio, DanmakuFilter, Download, Live, Match, Music, Pgc, SponsorBlock, Validate.
  - All 24 registered so `Get.find<>()` never crashes.
- `hasFeature()` => true for all 11 AppFeature values (declares full support; no runtime gating).
- Routes reuse: `routes => BiliBridge.registerRoutes()` — the ENTIRE bilibili page table; `homePage => const MainApp()` (bilibili `pages/main/view.dart`).

## Player

- `OttoPlayerFactory.create()` → OttoVideoPlayerController: lazily creates media_kit `Player` (PlayerConfiguration), implements full VideoPlayerController surface (open with MediaSource.uri + optional CoreMediaId/seekTo, play/pause/seek/setVolume/setSpeed, streams position/duration/playing/buffering/error→PlayerError). `reporter` field never assigned.
- OttoReporter: all 5 PlaybackReporter methods empty (`TODO(otto)`) — reporting not implemented.

## Vendored SDK

- `lib/ottohub_sdk_fix/` (root-level, path override for `ottohub_sdk_dart ^0.0.2`): pure Dart, dio ^5.10.0 + json_annotation, its OWN codegen stack (json_serializable + build_runner 2.15.1 + mocktail), own analysis_options.yaml. EXCLUDED from project analysis. SDK fixes go here, never pub.dev. OttohubClient exposes ~17 API modules (7 modern: video/auth/danmaku/following/moderation/... + 10 `old_*` modules).

## Conventions

- Real repos wrap SDK calls and convert SDK types → Core types inline (no ModelConverters equivalent — small surface).
- Stub methods: `=> _err(const ApiException('not_implemented'))`. Real methods use `on ApiException catch (e) { debugPrint(...); return Error(...); }`.

## Anti-patterns / caution

- Coupling to bilibili internals: otto_member_repository.dart imports `lib/adapters/bilibili/models_new/space/space_opus/*`; router/app_pages.dart hardcodes bilibili MainApp. Accepted for now (UI reuse) — keep NEW coupling minimal.
- hasFeature() returns true for all AppFeature values (adapter declares support; stub repos still return Error('not_implemented') — the crash-prevention contract).
- Stubs look implemented to `Get.find<>()` — a stub returning `Error('not_implemented')` is NOT a bug; it's the crash-prevention contract.

## Where to look

| Task | Location |
|---|---|
| Implement a missing repo | `repository/otto_<domain>_repository.dart` + register in bridge.dart, remove from stub list |
| Playback | `player/otto_player_factory.dart` (media_kit) |
| Account/token | `services/otto_account_provider.dart` (Hive-backed) |
| SDK behavior | `lib/ottohub_sdk_fix/` (vendored) |
