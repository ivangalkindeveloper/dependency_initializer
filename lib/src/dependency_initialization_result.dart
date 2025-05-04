import 'dart:async';

import 'package:dependency_initializer/dependency_initializer.dart';

/// Class that represents the result of a dependency initialization process.
///
/// This class contains the final result of the initialization process,
/// a list of steps that can be reinitialized, and a function to rerun
/// the initialization process if needed.
final class DependencyInitializationResult<Process, Result> {
  /// Creates a new [DependencyInitializationResult] instance.
  ///
  /// [result] - the final result of the initialization process.
  /// [reinitializationStepList] - list of steps that can be reinitialized.
  /// [reRun] - function to rerun the initialization process.
  const DependencyInitializationResult({
    required this.result,
    required this.reinitializationStepList,
    required this.repeat,
  });

  /// The final result of the initialization process.
  final Result result;

  /// List of steps that can be reinitialized.
  ///
  /// These steps are used when dependencies need to be reinitialized,
  /// for example when the environment changes.
  final List<DependencyInitializationStep<Process>> reinitializationStepList;

  /// Function to rerun the initialization process.
  ///
  /// This function allows reinitializing dependencies with optional
  /// customizations to the process, such as:
  /// - Custom process creation
  /// - Custom step list
  /// - Custom callbacks for process events
  final Future<void> Function({
    Process Function()? createProcess,
    List<DependencyInitializationStep<Process>>? stepList,
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
  }) repeat;
}
