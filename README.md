# Dependency initializer
Initializer utility of dependencies for Dart & Flutter projects.

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
  final List<DefaultInitializationStep<Process>> stepList = [
    ...coreStepList,
    ...dataStepList,
    ...blocStepList,
  ];
```

2) Create initializer and start initialize process:
```dart
  final Process process = Process();
  final Initializer initializer = Initializer<Process, Result>(
    process: process,
    stepList: stepList,
    onSuccess: (
      Result result,
      Duration duration,
    ) {
        // Success result of initialization
    },
  );
  await initializer.run();
```

# Usage cases
Initializer has several use cases:
1) As direct initialization
2) With completer initialization

# Additional information
For more details see example project.
And feel free to open an issue if you find any bugs or errors or suggestions.