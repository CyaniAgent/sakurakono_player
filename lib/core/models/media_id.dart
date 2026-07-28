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
