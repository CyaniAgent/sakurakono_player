import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局 Riverpod container —— AdapterRegistry.activate 后创建。
/// 非 widget 代码（controller/service）经 [appRead] 读取 provider，替代 `Get.find<T>()`。
late final ProviderContainer appContainer;

T appRead<T extends Object>(ProviderListenable<T> provider) => appContainer.read<T>(provider);