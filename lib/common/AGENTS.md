# AGENTS.md — lib/common (Shared Widgets)

## OVERVIEW

128 Dart files of reusable widgets with ZERO adapter imports (verified). The adapter-decoupled UI building-block layer. common⇄utils bidirectionally coupled; both import core.

## STRUCTURE

- root (4): constants.dart, assets.dart, dial_prefix.dart, style.dart
- skeleton/ (11): skeleton.dart + 10 layout variants (VideoCardHSkeleton, VideoCardVSkeleton, DynamicCardSkeleton, MediaPgcSkeleton, MsgFeedTopSkeleton...)
- widgets/ root (41): flat generic widgets
- widgets/flutter/ (24): VENDORED Flutter framework copies: text_field (2040ln), list_tile, chat_list_view, page/ (scrollable), text/. BSD-licensed forks, edit with care
- widgets/gesture/ (6): player_gesture_recognizer, horizontal_drag_gesture_recognizer (feeds deviceTouchSlop into Pref), immediate_tap, image_horizontal_drag, tap_gesture, mouse_interactive_viewer
- widgets/image_viewer/ (6): hero, viewer, loading_indicator, image, hero_dialog_route (gallery stack)
- widgets/sliver/ (6), loading_widget/ (4), button/ (3), dialog/ (3), progress_bar/ (3)
- widgets/image_grid/ (2), image/ (2), draggable_sheet/ (2), context_menu/ (2), svg/ (2), appbar/ (1), stat/ (1)
- widgets/dynamic_sliver_app_bar/ (3): incl. rendering/

## KEY WIDGETS

- LoadingWidget (loading_widget.dart): arc progress + msg, GetX Obx; sibling subdir (m3e_loading_indicator, morphs, http_error).
- CustomToast / NotifyWarning (custom_toast.dart): SmartDialog-based.
- PlayerBar (player_bar.dart): custom MultiChildRenderObjectWidget / RenderBottomBar (GPL header).
- VideoProgressIndicator / AudioVideoProgressBar / SegmentProgressBar (progress_bar/): custom render objects.
- DynamicSliverAppBar: own RenderSliverPersistentHeader stack.
- ImageViewer / GalleryViewer (image_viewer/), ImageGridView (image_grid/, needs ImageActionDelegate), NetworkImgLayer + CachedNetworkSvgImage (image/).
- Marquee, CustomTooltip (custom render-box tooltip), FloatingNavigationBar (600ln), SelfSizedHorizontalList, MultiSelectAppBarWidget, PBadge, Avatars, PendantAvatar, KeepAliveWrapper, ScaleApp.

## DELIBERATELY NOT HERE

- Danmaku: adapter-side (lib/adapters/bilibili/plugin/pl_player/); only utils/danmaku_utils.dart helper is shared.
- Player control chrome and video-list cards: adapter-specific. common provides building blocks (PlayerBar, progress bars, gestures) and skeleton placeholders only.

## CONVENTIONS

- `abstract final class` for statics-only (Style, Constants).
- Custom RenderObject style: pair XWidget with RenderX/_RenderX (PlayerBar, VideoProgressIndicator, CustomTooltip, AnimatedHeight, CustomHeightWidget, ExtraHitTestWidget, DynamicSliverAppBar). Flutter rendering surgery.
- PascalCase, no prefix (exception: PBadge). Private state _XState. GPLv3 headers on some files.
- GetX inside shared widgets: Obx, route_aware_mixin, reorder_mixin, SmartDialog.
- Style constants in style.dart (cardSpace 8, safeSpace 12, imgRadius 10, aspectRatio 16/10, topBarHeight 52, bottomSheetRadius 18).

## ANTI-PATTERNS

- NO imports from lib/adapters/. A widget becomes shared only when adapter-free. If it needs adapter data, it belongs in the adapter or takes data via constructor/ImageActionDelegate-style interface.
- Do not casually edit widgets/flutter/ (vendored Flutter framework). Changes there override framework behavior app-wide.
- common imports utils heavily (47 imports in 26 files). Do not invert: utils imports common only in 4 files (theme_utils→style, storage_pref→gesture, grid→skeleton/video_card_h, image_utils→constants).

## WHERE TO LOOK

| Task | Location |
|---|---|
| Loading/error UI | widgets/loading_widget/ + loading_widget.dart |
| Video progress/controls | widgets/progress_bar/ + player_bar.dart |
| Image grids/viewers | widgets/image_grid/, image_viewer/, image/ |
| List placeholders | skeleton/ |
| Shared style tokens | style.dart |
