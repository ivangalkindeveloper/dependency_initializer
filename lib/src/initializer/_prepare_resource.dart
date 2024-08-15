part of 'dependency_initializer.dart';

final class _PrepareResource<Process> {
  const _PrepareResource({
    required this.isolateController,
    required this.reinitializationStepList,
  });

  final _IsolateController? isolateController;
  final List<DependencyInitializationStep<Process>> reinitializationStepList;
}
