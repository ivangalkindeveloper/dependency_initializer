import 'dart:async';

import 'package:dependency_initializer/dependency_initializer.dart';

/// Type DIProcess - abbreviation for [DependencyInitializationProcess].
typedef DIProcess<T> = DependencyInitializationProcess<T>;

/// Type DIStep - abbreviation for [DependencyInitializationStep].
typedef DIStep = DependencyInitializationStep;

/// Type DIStepType - abbreviation for [DependencyInitializationStepType].
typedef DIStepType = DependencyInitializationStepType;

/// Type DIResult - abbreviation for [DependencyInitializationResult].
typedef DIResult<Process extends DIProcess, T>
    = DependencyInitializationResult<Process, T>;

/// Type DIResult - abbreviation for repeat function.
typedef DIRepeatFunction<Process extends DependencyInitializationProcess, T>
    = Future<void> Function({
  Process Function()? createProcess,
  List<DIStep>? steps,
  void Function(
    Completer<DIResult<Process, T>> completer,
  )? onStart,
  void Function(
    DIStep step,
  )? onStartStep,
  void Function(
    DIStep step,
    Duration stepDuration,
    Duration duration,
  )? onSuccessStep,
  void Function(
    DIResult<Process, T> result,
    Duration duration,
  )? onSuccess,
  void Function(
    Object error,
    StackTrace stackTrace,
    Process process,
    DIStep step,
    Duration duration,
  )? onError,
});
