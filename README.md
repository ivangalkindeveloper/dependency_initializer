# Dependency initializer
Initializer utility of dependencies for Dart & Flutter projects.
The utility does not depend on Flutter SDK to be able to use it for Dart projects as well.

# Usage
1) Prepare list of initialize steps:
```dart
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
```

2) Create initializer and start initialize process:
```dart
  final Initializer initializer = Initializer<Process, Result>(
    process: Process(),
    stepList: [
      ...coreStepList,
      ...dataStepList,
      ...blocStepList,
    ],
    onSuccess: (
      Result result,
      Duration duration,
    ) {
        // Success result of initialization
    },
  );
  await initializer.run();
```

# Use cases
Initializer has several use cases:
1) As direct flow initialization.
For example, if you want the Flutter application to show a native splash screen when it starts, and then launch the first widget.
```dart
  final Initializer initializer = Initializer<Process, Result>(
    process: Process(),
    stepList: stepList,
    onSuccess: (
      DependencyInitializationResult<Process, Result> initializationResult,
      Duration duration,
    ) => runApp(
      ApplicationWidget(
        result: initializationResult.result,
      ),
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      Process process,
      DependencyInitializationStep<Process> step,
      Duration duration,
    ) => runApp(
      const ApplicationErrorWidget(),
    ),
  );
  await initializer.run();
```

2) With completer initialization.
For example, you have a widget that displays its splash screen, and this widget must be rebuilt asynchronously using the initialization compiler.
```dart
  final Initializer initializer = Initializer<Process, Result>(
    process: Process(),
    stepList: stepList,
    onStart: (
      Completer<DependencyInitializationResult<Process, Result>> completer,
    ) => runApp(
      ApplicationWidget(
        completer: completer,
      ),
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      Process process,
      DependencyInitializationStep<Process> step,
      Duration duration,
    ) => runApp(
      const ApplicationErrorWidget(),
    ),
  );
  await initializer.run();
```

3) Reinitialization from result.
For example, in the runtime of a Flutter application, you need to reinitialize your new dependencies for the new environment and return the first widget of the Flutter application again.
```dart
  await initializationResult.reinitialization(
    process: Process(),
    stepList: newEnvironmentStepList,
    onSuccess: (
      DependencyInitializationResult<Process, Result> initializationResult,
      Duration duration,
    ) => runApp(
      ApplicationWidget(
        result: initializationResult.result,
      ),
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      Process process,
      DependencyInitializationStep<Process> step,
      Duration duration,
    ) => runApp(
      const ApplicationErrorWidget(),
    ),
  );
```

# Additional information
For more details see example project.
And feel free to open an issue if you find any bugs or errors or suggestions.