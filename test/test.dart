import 'dart:async';

import 'package:dependency_initializer/dependency_initializer.dart';
import 'package:test/test.dart';

import 'test_data.dart';
import 'test_dependency.dart';
import 'test_domain.dart';
import 'test_initialization_process.dart';

void main() {
  final dataStep = InitializationStep<InitializationProcess, Dependency>(
    run: (
      InitializationProcess process,
    ) {
      process.environment = const BaseEnvironment();
      process.client = HttpClient(
        environment: process.environment!,
      );
      process.api = EntityApi(
        client: process.client!,
      );
      process.database = EntityDatabase(
        environment: process.environment!,
      );
      process.repository = EntityRepository(
        api: process.api!,
        database: process.database!,
      );
    },
  );
  IsolatedInitializationStep<InitializationProcess, Dependency, String, CatFact>
      getIsolatedStep(
    int index,
    int second, {
    DIStepType type = DIStepType.simple,
  }) =>
          IsolatedInitializationStep<InitializationProcess, Dependency, String,
              CatFact>(
            type: type,
            isolatedKey: "InitialCatFact$index",
            run: (
              InitializationProcess process,
            ) async {
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

      setUp(
        () {
          process = InitializationProcess();
        },
      );

      test(
        "Step test",
        () => DependencyInitializer<InitializationProcess, Dependency>(
          createProcess: () => process,
          steps: [
            dataStep,
          ],
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
        ).run(),
      );

      test(
        "Isolated step test",
        () => DependencyInitializer<InitializationProcess, Dependency>(
          createProcess: () => process,
          steps: [
            dataStep,
            getIsolatedStep(0, 1),
            getIsolatedStep(1, 3),
            getIsolatedStep(2, 2),
          ],
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
        ).run(),
      );

      test(
        "Reinitialization test",
        () => DependencyInitializer<InitializationProcess, Dependency>(
          createProcess: () => process,
          steps: [
            dataStep,
            getIsolatedStep(0, 1, type: DIStepType.repeatable),
            getIsolatedStep(1, 3, type: DIStepType.repeatable),
            getIsolatedStep(2, 2, type: DIStepType.repeatable),
          ],
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
              dependency.environment,
              isNotNull,
            );
            expect(
              dependency.repository,
              isNotNull,
            );
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
        ).run(),
      );

      test(
        "Error step test",
        () => DependencyInitializer<InitializationProcess, Dependency>(
          createProcess: () => process,
          steps: [
            InitializationStep<InitializationProcess, Dependency>(
              title: "Error step",
              run: (
                InitializationProcess process,
              ) =>
                  throw Exception("Error"),
            ),
          ],
          onError: (
            Object error,
            StackTrace stackTrace,
            InitializationProcess process,
            DependencyInitializationStep step,
            Duration duration,
          ) {
            expect(
              step.title,
              equals("Error step"),
            );
            expect(
              error,
              isA<Exception>(),
            );
            expect(
              error.toString(),
              contains("Error"),
            );
          },
          onSuccess: (
            DependencyInitializationResult<InitializationProcess, Dependency>
                result,
            Duration duration,
          ) =>
              fail(
            "Success callback should not be called when error occurs",
          ),
        ).run(),
      );

      test(
        "Error isolated step test",
        () => DependencyInitializer<InitializationProcess, Dependency>(
          createProcess: () => process,
          steps: [
            IsolatedInitializationStep<InitializationProcess, Dependency,
                String, CatFact>(
              isolatedKey: "ErrorStep",
              run: (
                InitializationProcess process,
              ) =>
                  throw Exception("Error"),
            ),
          ],
          onError: (
            Object error,
            StackTrace stackTrace,
            InitializationProcess process,
            DependencyInitializationStep step,
            Duration duration,
          ) {
            expect(
              step.title,
              equals("Error step"),
            );
            expect(
              error,
              isA<Exception>(),
            );
            expect(
              error.toString(),
              contains("Error"),
            );
          },
          onSuccess: (
            DependencyInitializationResult<InitializationProcess, Dependency>
                result,
            Duration duration,
          ) =>
              fail(
            "Success callback should not be called when error occurs",
          ),
        ).run(),
      );
    },
  );
}
