import 'package:skf/core/plugin/data_source.dart';
import 'package:skf/core/plugin/plugin_registry.dart';

/// Abstract interface for a plugin that can be registered with the framework.
abstract class Plugin {
  /// A unique identifier for this plugin.
  String get name;

  /// Called when this plugin is registered with the [PluginRegistry].
  Future<void> onRegister(PluginRegistry registry);

  /// Optionally provides a [DataSource] for the given [sourceId].
  /// Return null if this plugin does not handle the requested source.
  DataSource? provideDataSource(String sourceId);
}
