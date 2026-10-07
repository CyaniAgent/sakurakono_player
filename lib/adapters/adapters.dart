import 'package:skf/adapters/ottohub/bridge.dart';
import 'package:skf/core/adapter/adapter_registry.dart';

/// Registers every adapter compiled into the app.
///
/// Currently only [OttoAdapter] is compiled in (the Bilibili adapter was
/// removed). The runtime-active adapter is resolved via the `ADAPTER`
/// dart-define (`--dart-define=ADAPTER=ottohub`); see
/// [AdapterRegistry.activate].
void registerAllAdapters() {
  AdapterRegistry.register(OttoAdapter());
}
