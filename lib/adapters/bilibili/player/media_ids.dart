// B站-specific media ID types. These extend CoreMediaId from core.
// @Deprecated annotations removed — these are the actual implementations.
import 'package:skf/core/models/media_id.dart' show CoreMediaId;

/// Bilibili BV id (e.g. "BV1xx411c7mD")
class CoreBvid extends CoreMediaId {
  const CoreBvid(super.id);
}

/// Bilibili AV id (e.g. "av170001")
class CoreAid extends CoreMediaId {
  const CoreAid(super.id);
}

/// Bilibili SS id (season/series)
class CoreSid extends CoreMediaId {
  const CoreSid(super.id);
}

/// Bilibili EP id (episode)
class CoreEpid extends CoreMediaId {
  const CoreEpid(super.id);
}

/// Bilibili live room id
class CoreRoomId extends CoreMediaId {
  const CoreRoomId(super.id);
}

/// Bilibili CID (content/chapter id)
class CoreCid extends CoreMediaId {
  const CoreCid(super.id);
}
