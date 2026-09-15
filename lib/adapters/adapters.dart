import 'package:skf/adapters/ottohub/bridge.dart';
import 'package:skf/core/adapter/adapter_registry.dart';

/// Registers every adapter compiled into the app.
///
/// The runtime-active adapter is chosen via the `ADAPTER` dart-define
/// (`flutter run --dart-define=ADAPTER=bilibili|ottohub`); see
/// [AdapterRegistry.activate].
void registerAllAdapters() {
  AdapterRegistry.register(OttoAdapter());
}
