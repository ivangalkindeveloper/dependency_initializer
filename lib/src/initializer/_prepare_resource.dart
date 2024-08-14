part of 'dependency_initializer.dart';

final class _PrepareResource<Process> {
  const _PrepareResource({
    required this.isolateController,
    required this.reInitializationStepList,
  });

  final _IsolateController? isolateController;
  final List<DependencyInitializationStep<Process>> reInitializationStepList;
}
