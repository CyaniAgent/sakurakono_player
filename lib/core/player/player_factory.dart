import 'package:skf/core/player/player_controller.dart';

/// Creates [VideoPlayerController] instances. Register via DI.
abstract class PlayerFactory {
  VideoPlayerController create();
}
