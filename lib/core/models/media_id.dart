/// Identifier for a media item. Subtypes represent different ID schemes
/// (BV, AV, EP, SS, room, local path, etc.).
sealed class CoreMediaId {
  final String id;
  const CoreMediaId(this.id);

  @override
  bool operator ==(Object other) => other is CoreMediaId && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@Deprecated('Use adapters/bilibili counterpart')
class CoreBvid extends CoreMediaId {
  const CoreBvid(super.id);
}

@Deprecated('Use adapters/bilibili counterpart')
class CoreAid extends CoreMediaId {
  const CoreAid(super.id);
}

@Deprecated('Use adapters/bilibili counterpart')
class CoreSid extends CoreMediaId {
  const CoreSid(super.id);
}

@Deprecated('Use adapters/bilibili counterpart')
class CoreEpid extends CoreMediaId {
  const CoreEpid(super.id);
}

@Deprecated('Use adapters/bilibili counterpart')
class CoreRoomId extends CoreMediaId {
  const CoreRoomId(super.id);
}

@Deprecated('Use adapters/bilibili counterpart')
class CoreCid extends CoreMediaId {
  const CoreCid(super.id);
}

class CoreLocalPath extends CoreMediaId {
  const CoreLocalPath(super.id);
}
