# Dependency initializer
DependencyInitializer is a convenient and understandable contract for initializing dependencies for further use.\
The main goal of this utility is to provide a clear assembly of a dependency container with initialization steps.\
Advantages:
1) Convenient configuration - creating your own initialization steps and filling the initialization process;
2) Error handling and providing initialization steps;
3) Re-initialization for steps that were created as repeated, for example, for changing the environment.

# Use cases
Dart - run the initializer, get a dependency container and use it during the lifetime of the program.
Flutter - run the initializer, get a dependency container, place it in the InheritedWidget, and then in any widget get it through the BuildContext using ```final dependencies = context.read<MyDependencyContainer>();```.

Important points for full use:
1) Initialization steps imply not only filling the initialization process, but also the possibility of your custom checks related to business logic requests.
2) Do not forget that in case of an initialization error, you can show the error screen, and by passing the result to this widget, you can restart the initialization process using reRun.
Identically as for a successful launch, a similar scenario works for a test application, in particular for changing the environment without restarting the application.

# Usage
1) Prepare list of initialize steps.
```dart
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
```

2) Create initializer and start initialize process:
```dart
  final DependencyInitializer initializer = DependencyInitializer<MyProcess, MyResult>(
    creteProcess: () => MyProcess(),
    stepList: [
      ...coreStepList,
      ...dataStepList,
      ...blocStepList,
    ],
    onSuccess: (
      DependencyInitializationResult<MyProcess, MyResult> initializationResult,
      Duration duration,
    ) {
        // Success result of initialization
        // For Flutter example: runApp(ApplicationWidget(result: result));
    },
  );
  await initializer.run();
```

# Usage examples
Initializer has several use cases:
1) Direct.\
For example, if you want the Flutter application to show a native splash screen when it starts, and then launch the first widget.
```dart
  final Initializer initializer = Initializer<MyProcess, MyResult>(
    creteProcess: () => MyProcess(),
    stepList: stepList,
    onSuccess: (
      DependencyInitializationResult<MyProcess, MyResult> initializationResult,
      Duration duration,
    ) => runApp(
      ApplicationWidget(
        result: initializationResult.result,
      ),
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      MyProcess process,
      DependencyInitializationStep<MyProcess> step,
      Duration duration,
    ) => runApp(
      const ApplicationErrorWidget(),
    ),
  );
  await initializer.run();
```

2) With async completer.\
For example, you have a widget that displays its splash screen, and this widget must be rebuilt asynchronously using the initialization compiler.
```dart
  final Initializer initializer = Initializer<MyProcess, MyResult>(
    creteProcess: () => MyProcess(),
    stepList: stepList,
    onStart: (
      Completer<DependencyInitializationResult<MyProcess, MyResult>> completer,
    ) => runApp(
      ApplicationWidget(
        completer: completer,
      ),
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      MyProcess process,
      DependencyInitializationStep<MyProcess> step,
      Duration duration,
    ) => runApp(
      const ApplicationErrorWidget(),
    ),
  );
  await initializer.run();
```

3) Reinitialization from result.\
For example, in the runtime of a Flutter application, you need to reinitialize your new dependencies for the new environment and return the first widget of the Flutter application again.
```dart
  await initializationResult.reRun(
    stepList: [
      InitializationStep(
        title: "Config",
        initialize: (
          MyProcess process,
        ) =>
            process.config = AnotherConfig(),
      ),
      ...initializationResult.reinitializationStepList,
    ],
    onSuccess: (
      DependencyInitializationResult<MyProcess, MyResult> initializationResult,
      Duration duration,
    ) => runApp(
      ApplicationWidget(
        result: initializationResult.result,
      ),
    ),
    onError: (
      Object? error,
      StackTrace stackTrace,
      MyProcess process,
      DependencyInitializationStep<MyProcess> step,
      Duration duration,
    ) => runApp(
      const ApplicationErrorWidget(),
    ),
  );
```

# Additional information
For more details see example project.
And feel free to open an issue if you find any bugs or errors or suggestions.