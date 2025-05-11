# Dependency initializer
DependencyInitializer is a convenient and understandable contract for initializing dependencies.\
The main goal is to provide a clear assembly of a dependency container with initialization steps.\
Advantages:
1) Convenient configuration - creating your own initialization steps and filling the initialization process;
2) Parallel computation of isolated steps in separate isolates;
3) Error handling;
4) Re-initialization for steps that were created as repeated, for example, for changing the environment.

# Use cases
Dart - run the initializer, get a dependency container and use it during the lifetime of the program.
Flutter - run the initializer, get a dependency container, place it in the InheritedWidget, and then in any widget get it through the BuildContext using ```final dependencies = context.read<MyDependencyContainer>();```.

Important points for full use:
1) Initialization steps imply not only filling the initialization process, but also the possibility of your custom checks related to business logic requests.
2) Do not forget that in case of an initialization error, you can show the error screen, and by passing the result to this widget, you can restart the initialization process using runRepeat.
Identically as for a successful launch, a similar scenario works for a test application, in particular for changing the environment without restarting the application.

# Usage
## Container
Create a container that will be the final result of all initialization:
```dart
final class Dependency {
  const Dependency({
    required this.environment,
    required this.repository,
    required this.initialCatFact,
  });

  final Environment environment;
  final Repository repository;
  final CatFact initialCatFact;
}
```
The container can contain not only dependency entities, but also the original domain models for business logic.
## Process
Create a process that will gradually fill up.
```dart
final class InitializationProcess extends DependencyInitializationProcess<Dependency> {
  Environment? environment;
  Client? client;
  Api? api;
  Database? database;
  Repository? repository;

  /// Converts isolated results into a container of type [T].
  ///
  /// [isolatedResults] - A map containing the results of isolated initialization steps.
  /// Returns a container of type [T] that contains all initialized dependencies.
  @override
  Dependency toContainer(
    Map<dynamic, dynamic> isolatedResults,
  ) => Dependency(
    environment: environment!,
    repository: repository!,
    initialCatFact: isolatedResults['InitialCatFact'],
  );
}
```
## Steps
[DependencyInitializationStepType](https://github.com/ivangalkindeveloper/dependency_initializer/blob/master/lib/src/dependency_initialization_step_type.dart) - step execution type:
simple - the step is executed once, this is useful for example for initializing Firebase, database and other integration packages.
repeatable - the step is executed and remembered for further repeated execution when calling re-initialization using the runRepeat function.
[InitializationStep](https://github.com/ivangalkindeveloper/dependency_initializer/blob/master/lib/src/dependency_initialization_step.dart) - async/async execution step in the current main isolate.
[IsolatedInitializationStep](https://github.com/ivangalkindeveloper/dependency_initializer/blob/master/lib/src/dependency_initialization_step.dart) - sync/async execution step in the new parallel isolate.
Prepare list of initialize steps:
```dart
final List<InitializationStep<MyProcess>> steps = [
  InitializationStep<InitializationProcess, Dependency>(
    title: "Data",
    run: (
      InitializationProcess process
    ) {
      process.environment = const BaseEnvironment();
      process.client = HttpClient(
        environment: process.environment!
        );
      process.api = EntityApi(
        client: process.client!
        );
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
      final CatFact initialCatFact = await process.repository!.getCatFact();
      return initialCatFact;
    },
  ),
];
```
## DependencyInitializer
Create initializer and start initialize process:
```dart
DependencyInitializer<InitializationProcess, Dependency>(
  createProcess: () => InitializationProcess(),
  steps: steps,
  onSuccess: (
    DependencyInitializationResult<InitializationProcess, Dependency>
    result,
    Duration duration,
  ) => runApp(
    Application(
      dependency: result.container,
    ),
  ),
  onError: (
    Object error,
    StackTrace stackTrace,
    InitializationProcess process,
    DependencyInitializationStep step,
    Duration duration,
  ) => runApp(
    ErrorApplication(
      error: error,
    ),
  ),
).run();
```

# Usage examples
Initializer has several use cases:
1) Direct.\
For example, if you want the Flutter application to show a native splash screen when it starts, and then launch the first widget.
```dart
DependencyInitializer<InitializationProcess, Dependency>(
  createProcess: () => InitializationProcess(),
  steps: steps,
  onSuccess: (
    DependencyInitializationResult<InitializationProcess, Dependency> result,
    Duration duration,
  ) => runApp(
    Application(
      dependency: result.container,
    ),
  ),
  onError: (
    Object error,
    StackTrace stackTrace,
    InitializationProcess process,
    DependencyInitializationStep step,
    Duration duration,
  ) => runApp(
    ErrorApplication(
      error: error,
    ),
  ),
).run();
```

2) With async completer.\
For example, you have a widget that displays its splash screen, and this widget must be rebuilt asynchronously using the initialization compiler.
```dart
DependencyInitializer<InitializationProcess, Dependency>(
  createProcess: () => InitializationProcess(),
  steps: steps,
  onStart: (
    Completer<DependencyInitializationResult<MyProcess, MyResult>> completer,
  ) => runApp(
    ApplicationWidget(
      completer: completer,
    ),
  ),
  onError: (
    Object error,
    StackTrace stackTrace,
    InitializationProcess process,
    DependencyInitializationStep step,
    Duration duration,
  ) => runApp(
    ErrorApplication(
      error: error,
    ),
  ),
).run();
```

3) Reinitialization from result.\
For example, in the runtime of a Flutter application, you need to reinitialize your new dependencies for the new environment and return the first widget of the Flutter application again.
```dart
  await result.runRepeat(
    steps: [
      InitializationStep<InitializationProcess, Dependency>(
        title: "Environment",
        run: (
          InitializationProcess process
        ) {
          process.environment = const NewEnvironment();
        },
      ),
      ...result.repeatSteps,
    ],
    onSuccess: (
      DependencyInitializationResult<InitializationProcess, Dependency> result,
      Duration duration,
    ) => runApp(
      Application(
        dependency: result.container,
      ),
    ),
    onError: (
      Object error,
      StackTrace stackTrace,
      InitializationProcess process,
      DependencyInitializationStep step,
      Duration duration,
    ) => runApp(
      ErrorApplication(
        error: error,
      ),
    ),
  );
```

# Additional information
For more details see example project.
And feel free to open an issue if you find any bugs or errors or suggestions.