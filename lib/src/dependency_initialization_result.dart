import 'dart:async';

import 'package:dependency_initializer/dependency_initializer.dart';

final class DependencyInitializationResult<Process, Result> {
  const DependencyInitializationResult({
    required this.result,
    required this.reinitializationStepList,
    required this.reinitialization,
  });

  final Result result;
  final List<DependencyInitializationStep<Process>> reinitializationStepList;
  final Future<void> Function({
    required Process process,
    required List<DependencyInitializationStep<Process>> stepList,
    void Function(
      Completer<DependencyInitializationResult<Process, Result>> completer,
    )? onStart,
    void Function(
      DependencyInitializationStep<Process> step,
    )? onStartStep,
    void Function(
      DependencyInitializationStep<Process> step,
      Duration duration,
    )? onSuccessStep,
    void Function(
      DependencyInitializationResult<Process, Result> result,
      Duration duration,
    )? onSuccess,
    void Function(
      Object error,
      StackTrace stackTrace,
      Process process,
      DependencyInitializationStep<Process> step,
      Duration duration,
    )? onError,
  }) reinitialization;
}
