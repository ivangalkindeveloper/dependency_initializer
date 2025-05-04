import '../core/config.dart';

abstract interface class Dao {
  const Dao();

  abstract final Config config;
}

final class MyDao implements Dao {
  const MyDao({
    required this.config,
  });

  @override
  final Config config;
}
