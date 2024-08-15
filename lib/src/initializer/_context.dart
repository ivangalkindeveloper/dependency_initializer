part of 'dependency_initializer.dart';

final class _Context<Process extends DependencyInitializationProcess<Result>,
    Result> {
  const _Context({
    required this.isolateController,
    required this.reinitializationStepList,
  });

  final _IsolateController<Process, Result>? isolateController;
  final List<DependencyInitializationStep<Process>> reinitializationStepList;
}
