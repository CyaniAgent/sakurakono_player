import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global Riverpod overrides collected during adapter registration.
///
/// Each adapter's [registerDependencies] method populates this list.
/// [main.dart] reads it after [AdapterRegistry.activate] to pass
/// the overrides to the root [ProviderScope].
///
/// This avoids modifying the [AppAdapter] interface in core/ while still
/// allowing adapter-specific repository implementations to be injected
/// into the Riverpod provider tree.
List<Override> adapterOverrides = [];
