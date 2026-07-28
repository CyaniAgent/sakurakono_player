/// DI container abstraction. Default implementation wraps GetX.
@Deprecated('Use BiliBridge.register() (GetX DI) directly instead.')
abstract class ServiceRegistry {
  void bind<T>(T Function() factory);
  T resolve<T>();
  bool isRegistered<T>();
}
