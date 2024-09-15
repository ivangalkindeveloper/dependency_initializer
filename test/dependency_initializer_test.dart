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
            InitializationStep(
              title: "Config",
              initialize: (
                Process process,
              ) =>
                  process.config = Config$(),
            ),
            InitializationStep(
              title: "HttpClient",
              initialize: (
                Process process,
              ) =>
                  process.client = HttpClient$(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Api",
              initialize: (
                Process process,
              ) =>
                  process.api = Api$(
                client: process.client!,
              ),
            ),
            InitializationStep(
              title: "Dao",
              initialize: (
                Process process,
              ) =>
                  process.dao = Dao$(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Storage",
              initialize: (
                Process process,
              ) =>
                  process.storage = Storage$(
                config: process.config!,
              ),
            ),
            InitializationStep(
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
            InitializationStep(
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
            createProcess: () => process,
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
            InitializationStep(
              title: "Config",
              isIsolated: true,
              initialize: (
                Process process,
              ) =>
                  process.config = Config$(),
            ),
            InitializationStep(
              title: "HttpClient",
              isIsolated: true,
              initialize: (
                Process process,
              ) =>
                  process.client = HttpClient$(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Api",
              isIsolated: true,
              initialize: (
                Process process,
              ) =>
                  process.api = Api$(
                client: process.client!,
              ),
            ),
            InitializationStep(
              title: "Dao",
              isIsolated: true,
              initialize: (
                Process process,
              ) =>
                  process.dao = Dao$(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Storage",
              isIsolated: true,
              initialize: (
                Process process,
              ) =>
                  process.storage = Storage$(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Repository",
              isIsolated: true,
              initialize: (
                Process process,
              ) =>
                  process.repository = Repository$(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
            ),
            InitializationStep(
              title: "Bloc",
              isIsolated: true,
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
            createProcess: () => process,
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
            ReInitializationStep(
              title: "Config",
              initialize: (
                Process process,
              ) =>
                  process.config = Config$(),
            ),
            ReInitializationStep(
              title: "HttpClient",
              initialize: (
                Process process,
              ) =>
                  process.client = HttpClient$(
                config: process.config!,
              ),
            ),
            ReInitializationStep(
              title: "Api",
              initialize: (
                Process process,
              ) =>
                  process.api = Api$(
                client: process.client!,
              ),
            ),
            ReInitializationStep(
              title: "Dao",
              initialize: (
                Process process,
              ) =>
                  process.dao = Dao$(
                config: process.config!,
              ),
            ),
            ReInitializationStep(
              title: "Storage",
              initialize: (
                Process process,
              ) =>
                  process.storage = Storage$(
                config: process.config!,
              ),
            ),
            ReInitializationStep(
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
            ReInitializationStep(
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
            createProcess: () => process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<Process, Result>
                  initializationResult,
              Duration duration,
            ) =>
                initializationResult.reRun(
              createProcess: () => Process(),
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
            ),
          );

          await initializer.run();
        },
      );
    },
  );
}
