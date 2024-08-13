import 'api.dart';
import 'dao.dart';
import 'storage.dart';

abstract interface class Repository {
  const Repository();

  abstract final Api api;
  abstract final Dao dao;
  abstract final Storage storage;
}

final class Repository$ extends Repository {
  const Repository$({
    required this.api,
    required this.dao,
    required this.storage,
  });

  @override
  final Api api;
  @override
  final Dao dao;
  @override
  final Storage storage;
}
