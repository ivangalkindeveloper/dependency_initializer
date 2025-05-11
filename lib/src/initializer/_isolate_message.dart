part of 'dependency_initializer.dart';

/// Base class for messages sent between isolates during initialization.
///
/// This sealed class defines the common structure for all isolate messages.
sealed class _IsolateMessage {
  const _IsolateMessage({
    required this.id,
  });

  /// Unique identifier for the message.
  final int id;
}

/// Message sent when an isolated initialization step completes successfully.
///
/// Contains the result of the initialization step.
final class _IsolateMessageSuccess extends _IsolateMessage {
  const _IsolateMessageSuccess({
    required super.id,
    required this.result,
  });

  /// Map containing the result of the initialization step.
  final Map<dynamic, dynamic> result;
}

/// Message sent when an isolated initialization step fails.
///
/// Contains error information and the step that failed.
final class _IsolateMessageError<
    Process extends DIProcess<T>,
    T,
    IsolatedKey extends dynamic,
    IsolatedResult extends dynamic> extends _IsolateMessage {
  const _IsolateMessageError({
    required super.id,
    required this.error,
    required this.stackTrace,
    required this.step,
  });

  /// The error that occurred during initialization.
  final Object error;

  /// Stack trace of the error.
  final StackTrace stackTrace;

  /// The step that failed during initialization.
  final IsolatedInitializationStep<Process, T, IsolatedKey, IsolatedResult>
      step;
}
