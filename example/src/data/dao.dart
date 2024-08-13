import '../core/config.dart';

abstract interface class Dao {
  const Dao();

  abstract final Config config;
}

final class Dao$ implements Dao {
  const Dao$({
    required this.config,
  });

  @override
  final Config config;
}
