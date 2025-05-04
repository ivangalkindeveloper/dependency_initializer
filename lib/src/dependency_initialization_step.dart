import 'dart:async';

/// Sealed class that represents a single step in the dependency initialization process.
///
/// This class defines the structure of an initialization step, including its title,
/// isolation requirements, and initialization function.
sealed class DependencyInitializationStep<Process> {
  /// Creates a new [DependencyInitializationStep] instance.
  ///
  /// [title] - optional title of the step for identification and logging.
  /// [isIsolated] - whether the step should be executed in an isolate.
  /// [initialize] - function that performs the actual initialization.
  const DependencyInitializationStep({
    required this.title,
    required this.isIsolated,
    required this.initialize,
  });

  /// Optional title of the step for identification and logging.
  final String? title;

  /// Whether the step should be executed in an isolate.
  ///
  /// If true, the step will be executed in a separate isolate to prevent
  /// blocking the main thread.
  final bool isIsolated;

  /// Function that performs the actual initialization.
  ///
  /// This function receives the current state of the initialization process
  /// and can modify it as needed.
  final FutureOr<void> Function(
    Process progress,
  ) initialize;
}

/// Class that represents a regular initialization step.
///
/// This class is used for steps that are executed only once during the initial
/// dependency initialization process.
class InitializationStep<Progress>
    extends DependencyInitializationStep<Progress> {
  /// Creates a new [InitializationStep] instance.
  ///
  /// [title] - optional title of the step for identification and logging.
  /// [isIsolated] - whether the step should be executed in an isolate.
  /// [initialize] - function that performs the actual initialization.
  const InitializationStep({
    super.title,
    super.isIsolated = false,
    required super.initialize,
  });
}

/// Class that represents a reinitialization step.
///
/// This class is used for steps that can be executed multiple times,
/// for example when the environment changes and dependencies need to be
/// reinitialized.
class RepeatInitializationStep<Progress>
    extends DependencyInitializationStep<Progress> {
  /// Creates a new [RepeatInitializationStep] instance.
  ///
  /// [title] - optional title of the step for identification and logging.
  /// [isIsolated] - whether the step should be executed in an isolate.
  /// [initialize] - function that performs the actual initialization.
  const RepeatInitializationStep({
    super.title,
    super.isIsolated = false,
    required super.initialize,
  });
}
