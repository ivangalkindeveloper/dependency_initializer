import 'package:example/core/data.dart';
import 'package:example/core/dependency.dart';
import 'package:dependency_initializer/dependency_initializer.dart';

final class InitializationProcess
    extends DependencyInitializationProcess<Dependency> {
  Environment? environment;
  Client? client;
  Api? api;
  Database? database;
  Repository? repository;

  @override
  Dependency toContainer(Map<dynamic, dynamic> isolatedResults) => Dependency(
    environment: environment!,
    repository: repository!,
    initialCatFact: isolatedResults['InitialCatFact'],
  );
}
