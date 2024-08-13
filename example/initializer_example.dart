import 'dart:async';
import 'dart:io';

import 'package:initializer/initializer.dart';

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
  final List<DefaultInitializationStep<Process>> coreStepList = [
    DefaultInitializationStep(
      title: "Config",
      initialize: (
        Process process,
      ) =>
          process.config = Config$(),
    ),
  ];
  final List<DefaultInitializationStep<Process>> dataStepList = [
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
  ];
  final List<DefaultInitializationStep<Process>> blocStepList = [
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
  final List<DefaultInitializationStep<Process>> stepList = [
    ...coreStepList,
    ...dataStepList,
    ...blocStepList,
  ];

  final Process process = Process();
  final Initializer initializer = Initializer<Process, Result>(
    process: process,
    stepList: stepList,
    onStart: (
      Completer<Result> completer,
      List<InitializationStep<Process>> stepList,
    ) =>
        stdout.write(
      "Initializer started",
    ),
    onStartStep: (
      InitializationStep<Process> step,
    ) =>
        stdout.write(
      "Step started: ${step.title}",
    ),
    onSuccessStep: (
      InitializationStep<Process> step,
      Duration duration,
    ) =>
        stdout.write(
      "Step finished: ${step.title} $duration",
    ),
    onSuccess: (
      Result result,
      Duration duration,
    ) =>
        stdout.write(
      "Initializer finished: $duration",
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      Process process,
      InitializationStep<Process> step,
    ) =>
        stdout.write(
      "Initializer error. Step: ${step.title} Error: $error $stackTrace",
    ),
  );
  await initializer.run();
}
