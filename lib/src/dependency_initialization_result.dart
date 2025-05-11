import 'package:dependency_initializer/dependency_initializer.dart';

final class DependencyInitializationResult<Process extends DIProcess, T> {
  const DependencyInitializationResult({
    required this.container,
    required this.isolatedResults,
    required this.repeatSteps,
    required this.runRepeat,
  });

  final T container;
  final Map<dynamic, dynamic> isolatedResults;
  final List<DependencyInitializationStep> repeatSteps;
  final DIRepeatFunction<Process, T> runRepeat;
}
