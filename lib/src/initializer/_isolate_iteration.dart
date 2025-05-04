part of 'dependency_initializer.dart';

/// Inner class that represents a single iteration of dependency initialization in an isolate.
///
/// This class is used to pass initialization data between the main isolate and worker isolates.
/// It contains all necessary information to perform a single initialization step in isolation.
final class _IsolateIteration<Process> {
  /// Creates a new [_IsolateIteration] instance.
  ///
  /// [sendPort] - port for sending the result back to the main isolate.
  /// [process] - the current state of the initialization process.
  /// [step] - the initialization step to be executed.
  const _IsolateIteration({
    required this.sendPort,
    required this.process,
    required this.step,
  });

  /// Port for sending the result back to the main isolate after step completion.
  final SendPort sendPort;

  /// Current state of the initialization process.
  final Process process;

  /// The initialization step to be executed in isolation.
  final DIStep<Process> step;
}
