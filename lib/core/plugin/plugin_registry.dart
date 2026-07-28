import 'package:get/get.dart';
import 'package:skf/core/plugin/data_source.dart';
import 'package:skf/core/plugin/plugin.dart';

/// Central registry for plugins, wrapping GetX dependency injection.
class PluginRegistry {
  final List<Plugin> _plugins = [];

  /// Register a plugin with GetX DI.
  /// The plugin's [onRegister] is called immediately, making the registry
  /// available for any cross-plugin setup.
  Future<void> register<T extends Plugin>(T plugin) async {
    _plugins.add(plugin);
    Get.put<T>(plugin);
    await plugin.onRegister(this);
  }

  /// Resolve a plugin of type [T] from GetX DI.
  /// Returns null if no plugin of type [T] is registered.
  T? resolve<T extends Plugin>() {
    try {
      return Get.find<T>();
    } catch (_) {
      return null;
    }
  }

  /// Returns all registered plugins.
  List<Plugin> all() => List.unmodifiable(_plugins);

  /// Find a [DataSource] for the given [sourceId] by querying all plugins.
  /// Returns the first DataSource provided by any plugin, or null.
  DataSource? getDataSource(String sourceId) {
    for (final plugin in _plugins) {
      final ds = plugin.provideDataSource(sourceId);
      if (ds != null) return ds;
    }
    return null;
  }
}
