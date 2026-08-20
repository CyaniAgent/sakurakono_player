# lib/player — Generic media_kit player core

Child of root AGENTS.md. Platform-agnostic playback engine; root rules (lints, package:skf imports) apply.

## Overview

27 Dart files, **0 adapter imports (verified)**. Generic media_kit player core implementing `CorePlayerService` (`lib/core/player/core_player_service.dart`). Adapter-specific playback builds on top via mixins (e.g. B站 `lib/adapters/bilibili/plugin/pl_player/bili_player_mixin.dart`).

## Layout

- `player_controller.dart`: `PlayerController implements CorePlayerService` — media_kit state machine (open/play/pause/seek/setVolume/setSpeed/dispose + events stream). Depends on `utils/`, `router/` (AppNavigator), Hive, wakelock_plus, native_device_orientation — NOT on adapters.
- `player_view.dart`: player UI shell.
- `models/` 17: enums & contracts — play_status, play_repeat, play_speed, video_fit_type, fullscreen_mode, gesture_type, double_tap_type, hwdec_type, heart_beat_type, bottom_control_type, bottom_progress_behavior, player_overlay_source, data_source, data_status, duration, enum_with_label, player_view_contracts.
- `utils/` 2: danmaku_options.dart, fullscreen.dart.
- `widgets/` 6: app_bar_ani, backward_seek, forward_seek, bottom_control, common_btn, video_time.

## Extensibility

- `lib/core/player/` exposes ONLY the `CorePlayerService` interface; pages depend on that interface, never on `PlayerController` directly.
- Adapters extend behavior via mixins over the core (`onPlayerInit`/`onOpenStart`/`onHeartBeat`/`onEnterPip` hooks) — see `lib/adapters/bilibili/plugin/pl_player/`.

## Where to look

| Task | Location |
|---|---|
| Player state machine | player_controller.dart |
| Player UI shell | player_view.dart |
| Playback enums/contracts | models/ |
| B站-specific playback | lib/adapters/bilibili/plugin/pl_player/ (mixin layer) |