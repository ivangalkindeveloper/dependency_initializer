part of 'dependency_initializer.dart';

/// Request object sent to an isolate to execute an initialization step.
///
/// Contains all necessary information for the isolate to run the step
/// and communicate back the results.
final class _IsolateRequest<Process extends DIProcess<T>, T,
    IsolatedKey extends dynamic, IsolatedResult extends dynamic> {
  const _IsolateRequest({
    required this.id,
    required this.sendPort,
    required this.process,
    required this.step,
  });

  /// Unique identifier for the request.
  final int id;

  /// Port used to send messages back to the main isolate.
  final SendPort sendPort;

  /// The initialization process instance.
  final Process process;

  /// The isolated initialization step to execute.
  final IsolatedInitializationStep<Process, T, IsolatedKey, IsolatedResult>
      step;
}
