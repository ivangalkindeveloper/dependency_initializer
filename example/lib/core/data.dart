import 'dart:convert';

import 'package:example/core/domain.dart';
import 'package:http/http.dart' as http;

abstract interface class Environment {
  const Environment();
}

final class BaseEnvironment implements Environment {
  const BaseEnvironment();
}

abstract interface class Client {
  const Client();

  abstract final Environment environment;

  Future<http.Response> get(Uri url);
}

final class HttpClient implements Client {
  const HttpClient({required this.environment});

  @override
  final Environment environment;

  @override
  Future<http.Response> get(Uri url) => http.get(url);
}

abstract interface class Api {
  const Api();

  abstract final Client client;

  Future<http.Response> getCatFact();
}

final class EntityApi implements Api {
  const EntityApi({required this.client});

  @override
  final Client client;

  @override
  Future<http.Response> getCatFact() =>
      client.get(Uri.parse("https://catfact.ninja/fact"));
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

  Future<CatFact> getCatFact();
}

final class EntityRepository extends Repository {
  const EntityRepository({required this.api, required this.database});

  @override
  final Api api;
  @override
  final Database database;

  @override
  Future<CatFact> getCatFact() async {
    final http.Response response = await api.getCatFact();
    return CatFact.fromJson(jsonDecode(response.body));
  }
}
