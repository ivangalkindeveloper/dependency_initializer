import 'package:dependency_initializer/dependency_initializer.dart';

import 'test_data.dart';
import 'test_dependency.dart';

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
        initialCatFact0: isolatedResults['InitialCatFact0'],
        initialCatFact1: isolatedResults['InitialCatFact1'],
        initialCatFact2: isolatedResults['InitialCatFact2'],
      );
}
