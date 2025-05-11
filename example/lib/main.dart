import 'package:dependency_initializer/dependency_initializer.dart';
import 'package:example/core/domain.dart';
import 'package:example/core/data.dart';
import 'package:example/core/dependency.dart';
import 'package:example/core/initialization_process.dart';
import 'package:example/widget/application.dart';
import 'package:example/widget/error_application.dart';
import 'package:flutter/cupertino.dart';

Future<void> main() =>
    DependencyInitializer<InitializationProcess, Dependency>(
      createProcess: () => InitializationProcess(),
      steps: [
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
        IsolatedInitializationStep<
          InitializationProcess,
          Dependency,
          String,
          CatFact
        >(
          title: "Cat Fact",
          isolatedKey: "InitialCatFact",
          run: (InitializationProcess process) async {
            final CatFact initialCatFact =
                await process.repository!.getCatFact();
            return initialCatFact;
          },
        ),
      ],
      onSuccess:
          (
            DependencyInitializationResult<InitializationProcess, Dependency>
            result,
            Duration duration,
          ) => runApp(Application(dependency: result.container)),
      onError:
          (
            Object error,
            StackTrace stackTrace,
            InitializationProcess process,
            DependencyInitializationStep step,
            Duration duration,
          ) => runApp(ErrorApplication(error: error)),
    ).run();
