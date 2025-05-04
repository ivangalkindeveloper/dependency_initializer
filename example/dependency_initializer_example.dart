import 'dart:async';
import 'dart:io';

import 'package:dependency_initializer/dependency_initializer.dart';

import 'src/bloc/bloc.dart';
import 'src/core/config.dart';
import 'src/data/api.dart';
import 'src/data/dao.dart';
import 'src/data/http_client.dart';
import 'src/data/repository.dart';
import 'src/data/storage.dart';
import 'src/process.dart';
import 'src/result.dart';

Future<void> main() async {
  final List<InitializationStep<MyProcess>> coreStepList = [
    InitializationStep(
      title: "Config",
      initialize: (
        MyProcess process,
      ) =>
          process.config = const MyConfig(),
    ),
  ];
  final List<InitializationStep<MyProcess>> dataStepList = [
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
  ];
  final List<InitializationStep<MyProcess>> blocStepList = [
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
    createProcess: () => MyProcess(),
    stepList: [
      ...coreStepList,
      ...dataStepList,
      ...blocStepList,
    ],
    onStart: (
      Completer<DependencyInitializationResult<MyProcess, MyResult>> completer,
    ) =>
        stdout.write(
      "Initializer started",
    ),
    onStartStep: (
      DependencyInitializationStep<MyProcess> step,
    ) =>
        stdout.write(
      "Step started: ${step.title}",
    ),
    onSuccessStep: (
      DependencyInitializationStep<MyProcess> step,
      Duration duration,
    ) =>
        stdout.write(
      "Step finished: ${step.title} $duration",
    ),
    onSuccess: (
      DependencyInitializationResult<MyProcess, MyResult> initializationResult,
      Duration duration,
    ) =>
        stdout.write(
      "Initializer finished: $duration",
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      MyProcess process,
      DependencyInitializationStep<MyProcess> step,
      Duration duration,
    ) =>
        stdout.write(
      "Initializer error. Step: ${step.title} $duration Error: $error $stackTrace",
    ),
  );
  await initializer.run();
}
