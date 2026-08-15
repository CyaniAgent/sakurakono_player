import 'package:skf/core/adapter/app_adapter.dart';

/// Registry that holds all registered adapters and activates one at a time.
class AdapterRegistry {
  static final Map<String, AppAdapter> _adapters = {};
  static AppAdapter? _active;

  /// The currently active adapter.
  static AppAdapter get active {
    if (_active == null) {
      throw StateError('No adapter activated. Call AdapterRegistry.activate() first.');
    }
    return _active!;
  }

  /// Register an adapter. Can be called before activate().
  static void register(AppAdapter adapter) {
    _adapters[adapter.name] = adapter;
  }

  /// Look up a registered adapter by name without activating it.
  static AppAdapter lookup(String name) {
    final adapter = _adapters[name];
    if (adapter == null) {
      throw ArgumentError("Adapter not registered: $name. Available: ${_adapters.keys}");
    }
    return adapter;
  }

  /// Activate the named adapter, registering its DI bindings.
  static Future<void> activate(String name) async {
    final target = lookup(name);
    _active = target;
    await target.registerDependencies();
  }
}
