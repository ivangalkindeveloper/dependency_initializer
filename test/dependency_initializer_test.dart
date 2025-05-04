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
      late MyProcess process;
      late List<DependencyInitializationStep<MyProcess>> stepList;

      setUp(
        () {
          process = MyProcess();
        },
      );

      test(
        "Main test",
        () async {
          stepList = [
            InitializationStep(
              title: "Config",
              initialize: (
                MyProcess process,
              ) =>
                  process.config = const MyConfig(),
            ),
            InitializationStep(
              title: "HttpClient",
              initialize: (
                MyProcess process,
              ) =>
                  process.client = MyHttpClient(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Api",
              initialize: (
                MyProcess process,
              ) =>
                  process.api = MyApi(
                client: process.client!,
              ),
            ),
            InitializationStep(
              title: "Dao",
              initialize: (
                MyProcess process,
              ) =>
                  process.dao = MyDao(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Storage",
              initialize: (
                MyProcess process,
              ) =>
                  process.storage = MyStorage(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Repository",
              initialize: (
                MyProcess process,
              ) =>
                  process.repository = MyRepository(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
            ),
            InitializationStep(
              title: "Bloc",
              initialize: (
                MyProcess process,
              ) =>
                  process.bloc = MyBloc(
                repository: process.repository!,
              ),
            ),
          ];

          final DependencyInitializer initializer =
              DependencyInitializer<MyProcess, MyResult>(
            createProcess: () => process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<MyProcess, MyResult>
                  initializationResult,
              Duration duration,
            ) {
              // MyProcess
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

              // MyResult
              final MyResult result = initializationResult.result;
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
                MyProcess process,
              ) =>
                  process.config = const MyConfig(),
            ),
            InitializationStep(
              title: "HttpClient",
              isIsolated: true,
              initialize: (
                MyProcess process,
              ) =>
                  process.client = MyHttpClient(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Api",
              isIsolated: true,
              initialize: (
                MyProcess process,
              ) =>
                  process.api = MyApi(
                client: process.client!,
              ),
            ),
            InitializationStep(
              title: "Dao",
              isIsolated: true,
              initialize: (
                MyProcess process,
              ) =>
                  process.dao = MyDao(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Storage",
              isIsolated: true,
              initialize: (
                MyProcess process,
              ) =>
                  process.storage = MyStorage(
                config: process.config!,
              ),
            ),
            InitializationStep(
              title: "Repository",
              isIsolated: true,
              initialize: (
                MyProcess process,
              ) =>
                  process.repository = MyRepository(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
            ),
            InitializationStep(
              title: "Bloc",
              isIsolated: true,
              initialize: (
                MyProcess process,
              ) =>
                  process.bloc = MyBloc(
                repository: process.repository!,
              ),
            ),
          ];

          final DependencyInitializer initializer =
              DependencyInitializer<MyProcess, MyResult>(
            createProcess: () => process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<MyProcess, MyResult>
                  initializationResult,
              Duration duration,
            ) {
              final MyResult result = initializationResult.result;
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
            RepeatInitializationStep(
              title: "Config",
              initialize: (
                MyProcess process,
              ) =>
                  process.config = const MyConfig(),
            ),
            RepeatInitializationStep(
              title: "HttpClient",
              initialize: (
                MyProcess process,
              ) =>
                  process.client = MyHttpClient(
                config: process.config!,
              ),
            ),
            RepeatInitializationStep(
              title: "Api",
              initialize: (
                MyProcess process,
              ) =>
                  process.api = MyApi(
                client: process.client!,
              ),
            ),
            RepeatInitializationStep(
              title: "Dao",
              initialize: (
                MyProcess process,
              ) =>
                  process.dao = MyDao(
                config: process.config!,
              ),
            ),
            RepeatInitializationStep(
              title: "Storage",
              initialize: (
                MyProcess process,
              ) =>
                  process.storage = MyStorage(
                config: process.config!,
              ),
            ),
            RepeatInitializationStep(
              title: "Repository",
              initialize: (
                MyProcess process,
              ) =>
                  process.repository = MyRepository(
                api: process.api!,
                dao: process.dao!,
                storage: process.storage!,
              ),
            ),
            RepeatInitializationStep(
              title: "Bloc",
              initialize: (
                MyProcess process,
              ) =>
                  process.bloc = MyBloc(
                repository: process.repository!,
              ),
            ),
          ];

          final DependencyInitializer initializer =
              DependencyInitializer<MyProcess, MyResult>(
            createProcess: () => process,
            stepList: stepList,
            onSuccess: (
              DependencyInitializationResult<MyProcess, MyResult>
                  initializationResult,
              Duration duration,
            ) =>
                initializationResult.repeat(
              createProcess: () => MyProcess(),
              onSuccess: (
                DependencyInitializationResult<MyProcess, MyResult>
                    initializationResult,
                Duration duration,
              ) {
                final MyResult result = initializationResult.result;
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
