import 'dart:async';

import 'package:dependency_initializer/dependency_initializer.dart';
import 'package:test/test.dart';

import 'dependency_initializer_test_data.dart';
import 'dependency_initializer_test_dependency.dart';
import 'dependency_initializer_test_domain.dart';
import 'dependency_initializer_test_process.dart';

void main() {
  IsolatedInitializationStep<InitializationProcess, Dependency, String, CatFact>
      getIsolatedStep(
    int index,
    int second, {
    DIStepType type = DIStepType.simple,
  }) =>
          IsolatedInitializationStep<InitializationProcess, Dependency, String,
              CatFact>(
            title: "Cat Fact $index",
            type: type,
            isolatedKey: "InitialCatFact$index",
            run: (InitializationProcess process) async {
              await Future.delayed(Duration(seconds: second));
              return CatFact(
                fact: "Cat fact $index",
                length: 0,
              );
            },
          );

  group(
    'Main group',
    () {
      late InitializationProcess process;
      late List<DependencyInitializationStep> steps;

      setUp(
        () {
          process = InitializationProcess();
        },
      );

      test(
        "Data step test",
        () async {
          steps = [
            InitializationStep<InitializationProcess, Dependency>(
              title: "Data",
              run: (InitializationProcess process) {
                process.environment = const BaseEnvironment();
                process.client = HttpClient(environment: process.environment!);
                process.api = EntityApi(client: process.client!);
                process.database = EntityDatabase(
                  environment: process.environment!,
                );
                process.repository = EntityRepository(
                  api: process.api!,
                  database: process.database!,
                );
              },
            ),
          ];

          await DependencyInitializer<InitializationProcess, Dependency>(
            createProcess: () => process,
            steps: steps,
            onSuccess: (
              DependencyInitializationResult<InitializationProcess, Dependency>
                  result,
              Duration duration,
            ) {
              expect(
                process.environment,
                isNotNull,
              );
              expect(
                process.client,
                isNotNull,
              );
              expect(
                process.api,
                isNotNull,
              );
              expect(
                process.database,
                isNotNull,
              );
              expect(
                process.repository,
                isNotNull,
              );

              final Dependency dependency = result.container;
              expect(
                dependency.environment,
                isNotNull,
              );
              expect(
                dependency.repository,
                isNotNull,
              );
            },
          ).run();
        },
      );

      test(
        "Isolated step test",
        () async {
          steps = [
            InitializationStep<InitializationProcess, Dependency>(
              title: "Data",
              run: (InitializationProcess process) {
                process.environment = const BaseEnvironment();
                process.client = HttpClient(environment: process.environment!);
                process.api = EntityApi(client: process.client!);
                process.database = EntityDatabase(
                  environment: process.environment!,
                );
                process.repository = EntityRepository(
                  api: process.api!,
                  database: process.database!,
                );
              },
            ),
            getIsolatedStep(0, 1),
            getIsolatedStep(1, 3),
            getIsolatedStep(2, 2),
          ];

          await DependencyInitializer<InitializationProcess, Dependency>(
            createProcess: () => process,
            steps: steps,
            onSuccess: (
              DependencyInitializationResult<InitializationProcess, Dependency>
                  result,
              Duration duration,
            ) {
              final Dependency dependency = result.container;
              expect(
                dependency.initialCatFact0,
                isNotNull,
              );
              expect(
                dependency.initialCatFact1,
                isNotNull,
              );
              expect(
                dependency.initialCatFact2,
                isNotNull,
              );
            },
          ).run();
        },
      );

      test(
        "Reinitialization test",
        () async {
          steps = [
            InitializationStep<InitializationProcess, Dependency>(
              title: "Data",
              type: DIStepType.repeatable,
              run: (InitializationProcess process) {
                process.environment = const BaseEnvironment();
                process.client = HttpClient(environment: process.environment!);
                process.api = EntityApi(client: process.client!);
                process.database = EntityDatabase(
                  environment: process.environment!,
                );
                process.repository = EntityRepository(
                  api: process.api!,
                  database: process.database!,
                );
              },
            ),
            getIsolatedStep(0, 1, type: DIStepType.repeatable),
            getIsolatedStep(1, 3, type: DIStepType.repeatable),
            getIsolatedStep(2, 2, type: DIStepType.repeatable),
          ];

          await DependencyInitializer<InitializationProcess, Dependency>(
            createProcess: () => process,
            steps: steps,
            onSuccess: (
              DependencyInitializationResult<InitializationProcess, Dependency>
                  result,
              Duration duration,
            ) async {
              expect(
                process.environment,
                isNotNull,
              );
              expect(
                process.client,
                isNotNull,
              );
              expect(
                process.api,
                isNotNull,
              );
              expect(
                process.database,
                isNotNull,
              );
              expect(
                process.repository,
                isNotNull,
              );

              final Dependency dependency = result.container;
              expect(
                dependency.initialCatFact0,
                isNotNull,
              );
              expect(
                dependency.initialCatFact1,
                isNotNull,
              );
              expect(
                dependency.initialCatFact2,
                isNotNull,
              );

              process = InitializationProcess();
              await result.runRepeat(
                onSuccess: (
                  DependencyInitializationResult<InitializationProcess,
                          Dependency>
                      result,
                  Duration duration,
                ) {
                  expect(
                    process.environment,
                    isNotNull,
                  );
                  expect(
                    process.client,
                    isNotNull,
                  );
                  expect(
                    process.api,
                    isNotNull,
                  );
                  expect(
                    process.database,
                    isNotNull,
                  );
                  expect(
                    process.repository,
                    isNotNull,
                  );

                  final Dependency dependency = result.container;
                  expect(
                    dependency.initialCatFact0,
                    isNotNull,
                  );
                  expect(
                    dependency.initialCatFact1,
                    isNotNull,
                  );
                  expect(
                    dependency.initialCatFact2,
                    isNotNull,
                  );
                },
              );
            },
          ).run();
        },
      );
    },
  );
}
