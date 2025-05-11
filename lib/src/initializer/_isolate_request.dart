part of 'dependency_initializer.dart';

final class _IsolateRequest<Process extends DIProcess<T>, T,
    IsolatedKey extends dynamic, IsolatedResult extends dynamic> {
  const _IsolateRequest({
    required this.id,
    required this.sendPort,
    required this.process,
    required this.step,
  });

  final int id;
  final SendPort sendPort;
  final Process process;
  final IsolatedInitializationStep<Process, T, IsolatedKey, IsolatedResult>
      step;
}
