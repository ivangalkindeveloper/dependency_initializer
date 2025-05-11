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

  final String? title;
  final DIStepType type;
}

final class InitializationStep<Process extends DIProcess<T>, T> extends DIStep {
  const InitializationStep({
    super.title,
    super.type,
    required this.run,
  });

  final FutureOr<void> Function(
    Process process,
  ) run;
}

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

  final bool errorsAreFatal;
  final String? debugName;
  final IsolatedKey isolatedKey;
  final FutureOr<IsolatedResult> Function(
    Process process,
  ) run;
}
