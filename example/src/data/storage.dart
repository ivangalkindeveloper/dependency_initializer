import '../core/config.dart';

abstract interface class Storage {
  const Storage();

  abstract final Config config;
}

final class MyStorage implements Storage {
  const MyStorage({
    required this.config,
  });

  @override
  final Config config;
}
