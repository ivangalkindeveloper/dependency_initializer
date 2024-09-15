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
  final List<InitializationStep<Process>> coreStepList = [
    InitializationStep(
      title: "Config",
      initialize: (
        Process process,
      ) =>
          process.config = Config$(),
    ),
  ];
  final List<InitializationStep<Process>> dataStepList = [
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
  ];
  final List<InitializationStep<Process>> blocStepList = [
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
    createProcess: () => Process(),
    stepList: [
      ...coreStepList,
      ...dataStepList,
      ...blocStepList,
    ],
    onStart: (
      Completer<DependencyInitializationResult<Process, Result>> completer,
    ) =>
        stdout.write(
      "Initializer started",
    ),
    onStartStep: (
      DependencyInitializationStep<Process> step,
    ) =>
        stdout.write(
      "Step started: ${step.title}",
    ),
    onSuccessStep: (
      DependencyInitializationStep<Process> step,
      Duration duration,
    ) =>
        stdout.write(
      "Step finished: ${step.title} $duration",
    ),
    onSuccess: (
      DependencyInitializationResult<Process, Result> initializationResult,
      Duration duration,
    ) =>
        stdout.write(
      "Initializer finished: $duration",
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      Process process,
      DependencyInitializationStep<Process> step,
      Duration duration,
    ) =>
        stdout.write(
      "Initializer error. Step: ${step.title} $duration Error: $error $stackTrace",
    ),
  );
  await initializer.run();
}
