import '../core/config.dart';

abstract interface class Storage {
  const Storage();

  abstract final Config config;
}

final class Storage$ implements Storage {
  const Storage$({
    required this.config,
  });

  @override
  final Config config;
}
