import 'package:initializer/initializer.dart';
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
      late List<InitializationStep<Process>> stepList;

      setUp(
        () {
          process = Process();
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
        },
      );

      test(
        "Resource test",
        () async {
          final Initializer initializer = Initializer<Process, Result>(
            process: process,
            stepList: stepList,
            onSuccess: (
              Result result,
              Duration duration,
            ) {
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
            },
          );

          await initializer.run();
        },
      );
    },
  );
}
