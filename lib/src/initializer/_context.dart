part of 'dependency_initializer.dart';

final class _Context<Process extends DIProcess<T>, T> {
  _Context({
    required this.process,
    required this.completer,
    required this.stopwatch,
    required this.isolateController,
    required this.isolatedResults,
    required this.steps,
    required this.isolatedSteps,
    required this.repeatSteps,
  });

  final Process process;
  final Completer<DIResult<Process, T>> completer;
  final Stopwatch stopwatch;
  final _IsolateController<Process, T>? isolateController;
  final Map<dynamic, dynamic> isolatedResults;
  final List<InitializationStep<Process, T>> steps;
  final List<IsolatedInitializationStep<Process, T, dynamic, dynamic>>
      isolatedSteps;
  final List<DIStep> repeatSteps;
  Object? error;
  StackTrace? stackTrace;

  void start() {
    stopwatch.start();
  }

  void catchError(
    Object error,
    StackTrace? stackTrace,
  ) {
    stopwatch.stop();
    completer.completeError(
      error,
      stackTrace,
    );
    this.isolateController?.close();
    error = error;
    stackTrace = stackTrace;
  }

  void finish(
    DIResult<Process, T> result,
  ) {
    completer.complete(
      result,
    );
    stopwatch.stop();
    this.isolateController?.close();
  }
}
