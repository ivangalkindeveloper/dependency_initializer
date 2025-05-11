abstract interface class Environment {
  const Environment();
}

final class BaseEnvironment implements Environment {
  const BaseEnvironment();
}

abstract interface class Client {
  const Client();

  abstract final Environment environment;
}

final class HttpClient implements Client {
  const HttpClient({required this.environment});

  @override
  final Environment environment;
}

abstract interface class Api {
  const Api();

  abstract final Client client;
}

final class EntityApi implements Api {
  const EntityApi({required this.client});

  @override
  final Client client;
}

abstract interface class Database {
  const Database();

  abstract final Environment environment;
}

final class EntityDatabase implements Database {
  const EntityDatabase({required this.environment});

  @override
  final Environment environment;
}

abstract interface class Repository {
  const Repository();

  abstract final Api api;
  abstract final Database database;
}

final class EntityRepository extends Repository {
  const EntityRepository({required this.api, required this.database});

  @override
  final Api api;
  @override
  final Database database;
}
