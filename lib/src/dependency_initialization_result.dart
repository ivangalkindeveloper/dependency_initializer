import 'package:dependency_initializer/dependency_initializer.dart';

final class DependencyInitializaionResult<Process, Result> {
  const DependencyInitializaionResult({
    required this.result,
    required this.reinitializationStepList,
    required this.reinitialization,
  });

  final Result result;
  final List<DependencyInitializationStep<Process>> reinitializationStepList;
  final Future<Result> Function({
    required List<DependencyInitializationStep<Process>> stepList,
  }) reinitialization;
}
