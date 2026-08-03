import 'package:skf/core/adapter/app_adapter.dart';

/// Registry that holds all registered adapters and activates one at a time.
class AdapterRegistry {
  static final Map<String, AppAdapter> _adapters = {};
  static AppAdapter? _active;

  /// All registered adapter names.
  static Set<String> get availableNames => _adapters.keys.toSet();

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

  /// Activate the named adapter, registering its DI bindings.
  static Future<void> activate(String name) async {
    final adapter = _adapters[name];
    if (adapter == null) {
      throw ArgumentError('Adapter not registered: $name. Available: ${_adapters.keys}');
    }
    _active = adapter;
    await adapter.registerDependencies();
  }

  /// Whether the active adapter supports a feature.
  static bool hasFeature(AppFeature feature) {
    return _active?.hasFeature(feature) ?? false;
  }
}
