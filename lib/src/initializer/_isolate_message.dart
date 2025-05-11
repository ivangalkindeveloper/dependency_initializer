part of 'dependency_initializer.dart';

sealed class _IsolateMessage {
  const _IsolateMessage({
    required this.id,
  });

  final int id;
}

final class _IsolateMessageSuccess extends _IsolateMessage {
  const _IsolateMessageSuccess({
    required super.id,
    required this.result,
  });

  final Map<dynamic, dynamic> result;
}

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

  final Object error;
  final StackTrace stackTrace;
  final IsolatedInitializationStep<Process, T, IsolatedKey, IsolatedResult>
      step;
}
