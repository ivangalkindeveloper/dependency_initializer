part of 'dependency_initializer.dart';

/// Internal class that manages the state and lifecycle of a dependency initialization process.
///
/// This class holds all the necessary context for running initialization steps,
/// including the process instance, completion state, timing information, and results.
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

  /// The current initialization process instance.
  final Process process;

  /// Completer used to signal the completion of the initialization process.
  final Completer<DIResult<Process, T>> completer;

  /// Stopwatch for tracking the duration of the initialization process.
  final Stopwatch stopwatch;

  /// Controller for managing isolated initialization steps.
  final _IsolateController<Process, T>? isolateController;

  /// Map to store results from isolated initialization steps.
  final Map<dynamic, dynamic> isolatedResults;

  /// List of regular initialization steps to be executed.
  final List<InitializationStep<Process, T>> steps;

  /// List of isolated initialization steps to be executed.
  final List<IsolatedInitializationStep<Process, T, dynamic, dynamic>>
      isolatedSteps;

  /// List of steps that can be repeated if needed.
  final List<DIStep> repeatSteps;

  /// Error that occurred during initialization, if any.
  Object? error;

  /// Stack trace of the error, if any.
  StackTrace? stackTrace;

  /// Starts the initialization process timer.
  void start() {
    stopwatch.start();
  }

  /// Handles an error that occurred during initialization.
  ///
  /// Stops the timer, completes the completer with an error,
  /// and closes the isolate controller if present.
  void catchError(
    Object error,
    StackTrace? stackTrace,
  ) {
    this.stopwatch.stop();
    this.completer.completeError(
          error,
          stackTrace,
        );
    this.isolateController?.close();
    this.error = error;
    this.stackTrace = stackTrace;
  }

  /// Completes the initialization process successfully.
  ///
  /// Completes the completer with the result, stops the timer,
  /// and closes the isolate controller if present.
  void finish(
    DIResult<Process, T> result,
  ) {
    this.stopwatch.stop();
    this.completer.complete(
          result,
        );
    this.isolateController?.close();
  }
}
