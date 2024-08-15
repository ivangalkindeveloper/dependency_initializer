import 'dart:async';

import 'package:dependency_initializer/dependency_initializer.dart';
import 'package:test/test.dart';

import '../example/src/bloc/bloc.dart';
import '../example/src/core/config.dart';
import '../example/src/data/api.dart';
import '../example/src/data/dao.dart';
import '../example/src/data/http_client.dart';
import '../example/src/data/repository.dart';
import '../example/src/data/storage.dart';
import '../example/src/process.dart';
import '../example/src/result.dart';

Future<void> main() async {
  group(
    'Main test group',
    () {
      late Process process;
      late List<DependencyInitializationStep<Process>> stepList;

      setUp(
        () {
          process = Process();
        },
      );

      test(
        "Resource test",
        () async {
          stepList = [
            DefaultInitializationStep(
              title: "Config",
              initialize: (
                Process process,
              ) =>
                  process.config = Config$(),
            ),
            DefaultInitializationStep(
              title: "HttpClient",
              initialize: (
                Process process,
              ) =>
                  process.client = HttpClient$(
                config: process.config!,
              ),
            ),
            DefaultInitializationStep(
              title: "Api",
              initialize: (
                Process process,
              ) =>
                  process.api = Api$(
                client: process.client!,
              ),
            ),
            DefaultInitializationStep(
              title: "Dao",
              initialize: (
                Process process,
              ) =>
                  process.dao = Dao$(
                config: process.config!,
              ),
            ),
            DefaultInitializationStep(
              title: "Storage",
              initialize: (
                Process process,
              ) =>
                  process.storage = Storage$(
                config: process.config!,
              ),
            ),
            DefaultInitializationStep(
              title: "Repository",
              initialize: (
                Process process,
              ) =>
                  process.repository = Repository$(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
            ),
            DefaultInitializationStep(
              title: "Bloc",
              initialize: (
                Process process,
              ) =>
                  process.bloc = Bloc(
                repository: process.repository!,
              ),
            ),
          ];

          final DependencyInitializer initializer =
              DependencyInitializer<Process, Result>(
            process: process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<Process, Result>
                  initializationResult,
              Duration duration,
            ) {
              // Process
              expect(
                process.api,
                isNotNull,
              );
              expect(
                process.bloc,
                isNotNull,
              );
              expect(
                process.client,
                isNotNull,
              );
              expect(
                process.config,
                isNotNull,
              );
              expect(
                process.dao,
                isNotNull,
              );
              expect(
                process.repository,
                isNotNull,
              );
              expect(
                process.storage,
                isNotNull,
              );

              // Result
              final Result result = initializationResult.result;
              expect(
                result.config,
                isNotNull,
              );
              expect(
                result.repository,
                isNotNull,
              );
              expect(
                result.bloc,
                isNotNull,
              );
            },
          );

          await initializer.run();
        },
      );

      test(
        "Isolate test",
        () async {
          stepList = [
            DefaultInitializationStep(
              title: "Config",
              initialize: (
                Process process,
              ) =>
                  process.config = Config$(),
              isIsolated: true,
            ),
            DefaultInitializationStep(
              title: "HttpClient",
              initialize: (
                Process process,
              ) =>
                  process.client = HttpClient$(
                config: process.config!,
              ),
              isIsolated: true,
            ),
            DefaultInitializationStep(
              title: "Api",
              initialize: (
                Process process,
              ) =>
                  process.api = Api$(
                client: process.client!,
              ),
              isIsolated: true,
            ),
            DefaultInitializationStep(
              title: "Dao",
              initialize: (
                Process process,
              ) =>
                  process.dao = Dao$(
                config: process.config!,
              ),
              isIsolated: true,
            ),
            DefaultInitializationStep(
              title: "Storage",
              initialize: (
                Process process,
              ) =>
                  process.storage = Storage$(
                config: process.config!,
              ),
              isIsolated: true,
            ),
            DefaultInitializationStep(
              title: "Repository",
              initialize: (
                Process process,
              ) =>
                  process.repository = Repository$(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
              isIsolated: true,
            ),
            DefaultInitializationStep(
              title: "Bloc",
              initialize: (
                Process process,
              ) =>
                  process.bloc = Bloc(
                repository: process.repository!,
              ),
              isIsolated: true,
            ),
          ];

          final DependencyInitializer initializer =
              DependencyInitializer<Process, Result>(
            process: process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<Process, Result>
                  initializationResult,
              Duration duration,
            ) {
              final Result result = initializationResult.result;
              expect(
                result.config,
                isNotNull,
              );
              expect(
                result.repository,
                isNotNull,
              );
              expect(
                result.bloc,
                isNotNull,
              );
            },
          );

          await initializer.run();
        },
      );

      test(
        "Reinitialization test",
        () async {
          stepList = [
            DefaultInitializationStep(
              title: "Config",
              initialize: (
                Process process,
              ) =>
                  process.config = Config$(),
              isReinitialized: true,
            ),
            DefaultInitializationStep(
              title: "HttpClient",
              initialize: (
                Process process,
              ) =>
                  process.client = HttpClient$(
                config: process.config!,
              ),
              isReinitialized: true,
            ),
            DefaultInitializationStep(
              title: "Api",
              initialize: (
                Process process,
              ) =>
                  process.api = Api$(
                client: process.client!,
              ),
              isReinitialized: true,
            ),
            DefaultInitializationStep(
              title: "Dao",
              initialize: (
                Process process,
              ) =>
                  process.dao = Dao$(
                config: process.config!,
              ),
              isReinitialized: true,
            ),
            DefaultInitializationStep(
              title: "Storage",
              initialize: (
                Process process,
              ) =>
                  process.storage = Storage$(
                config: process.config!,
              ),
              isReinitialized: true,
            ),
            DefaultInitializationStep(
              title: "Repository",
              initialize: (
                Process process,
              ) =>
                  process.repository = Repository$(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
              isReinitialized: true,
            ),
            DefaultInitializationStep(
              title: "Bloc",
              initialize: (
                Process process,
              ) =>
                  process.bloc = Bloc(
                repository: process.repository!,
              ),
              isReinitialized: true,
            ),
          ];

          final DependencyInitializer initializer =
              DependencyInitializer<Process, Result>(
            process: process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<Process, Result>
                  initializationResult,
              Duration duration,
            ) async {
              await initializationResult.reinitialization(
                process: Process(),
                stepList: stepList,
                onSuccess: (
                  DependencyInitializationResult<Process, Result>
                      initializationResult,
                  Duration duration,
                ) {
                  final Result result = initializationResult.result;
                  expect(
                    result.config,
                    isNotNull,
                  );
                  expect(
                    result.repository,
                    isNotNull,
                  );
                  expect(
                    result.bloc,
                    isNotNull,
                  );
                },
              );
            },
          );

          await initializer.run();
        },
      );
    },
  );
}
