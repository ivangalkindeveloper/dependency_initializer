part of 'dependency_initializer.dart';

final class _IsolateIteration<Process> {
  const _IsolateIteration({
    required this.sendPort,
    required this.process,
    required this.step,
  });

  final SendPort sendPort;
  final Process process;
  final DependencyInitializationStep<Process> step;
}
