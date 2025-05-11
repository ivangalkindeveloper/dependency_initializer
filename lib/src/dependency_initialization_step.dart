import 'dart:async';

import 'package:dependency_initializer/src/typedef.dart';

/// Sealed class that represents a single step in the dependency initialization process.
///
/// This class defines the structure of an initialization step, including its title,
/// isolation requirements, and initialization function.
sealed class DependencyInitializationStep {
  const DependencyInitializationStep({
    this.title,
    this.type = DIStepType.simple,
  });

  /// Optional title for the initialization step.
  final String? title;

  /// Type of the initialization step, defaults to [DIStepType.simple].
  final DIStepType type;
}

/// A concrete implementation of [DependencyInitializationStep] for simple initialization steps.
///
/// This class represents a step that runs in the main isolate and doesn't require isolation.
final class InitializationStep<Process extends DIProcess<T>, T> extends DIStep {
  const InitializationStep({
    super.title,
    super.type,
    required this.run,
  });

  /// The function that performs the initialization step.
  ///
  /// Takes a [Process] instance as a parameter and returns a [FutureOr<void>].
  final FutureOr<void> Function(
    Process process,
  ) run;
}

/// A concrete implementation of [DependencyInitializationStep] for isolated initialization steps.
///
/// This class represents a step that runs in a separate isolate to prevent blocking
/// the main thread during heavy initialization tasks.
final class IsolatedInitializationStep<
    Process extends DIProcess<T>,
    T,
    IsolatedKey extends dynamic,
    IsolatedResult extends dynamic> extends DIStep {
  const IsolatedInitializationStep({
    super.title,
    super.type,
    this.errorsAreFatal = true,
    this.debugName,
    required this.isolatedKey,
    required this.run,
  });

  /// Whether errors in this step should be considered fatal for the entire initialization process.
  final bool errorsAreFatal;

  /// Optional debug name for the isolate running this step.
  final String? debugName;

  /// Key used to store the result of this isolated step.
  final IsolatedKey isolatedKey;

  /// The function that performs the isolated initialization step.
  ///
  /// Takes a [Process] instance as a parameter and returns a [FutureOr<IsolatedResult>].
  final FutureOr<IsolatedResult> Function(
    Process process,
  ) run;
}
