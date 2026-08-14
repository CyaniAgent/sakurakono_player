/// Identifier for a media item. Subtypes represent different ID schemes
/// (BV, AV, EP, SS, room, local path, etc.).
abstract class CoreMediaId {
  final String id;
  const CoreMediaId(this.id);

  @override
  bool operator ==(Object other) => other is CoreMediaId && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CoreLocalPath extends CoreMediaId {
  const CoreLocalPath(super.id);
}

/// Bilibili BV ID, e.g. "BV1xx411c7mD".
class CoreBvId extends CoreMediaId {
  const CoreBvId(super.id);
}

/// Bilibili AV ID, e.g. "av170001" or bare numeric "170001".
class CoreAvId extends CoreMediaId {
  const CoreAvId(super.id);
}

/// Bilibili episode (ep) ID for PGC series.
class CoreEpId extends CoreMediaId {
  const CoreEpId(super.id);
}

/// Bilibili season (ss) ID for PGC series.
class CoreSeasonId extends CoreMediaId {
  const CoreSeasonId(super.id);
}

/// Bilibili live room ID.
class CoreRoomId extends CoreMediaId {
  const CoreRoomId(super.id);
}

/// Bilibili video part (cid) ID.
class CoreCid extends CoreMediaId {
  const CoreCid(super.id);
}

/// Generic pure-numeric media ID (e.g. OttoHub video id).
class CoreNumericId extends CoreMediaId {
  const CoreNumericId(super.id);
}
