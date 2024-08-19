import 'dart:async';

abstract class DependencyInitializationStep<Process> {
  abstract final String? title;
  abstract final bool isIsolated;
  abstract final bool isReinitialized;
  abstract final FutureOr<void> Function(
    Process progress,
  ) initialize;
}

class DefaultInitializationStep<Progress>
    implements DependencyInitializationStep<Progress> {
  const DefaultInitializationStep({
    this.title,
    this.isIsolated = false,
    this.isReinitialized = false,
    required this.initialize,
  });

  @override
  final String? title;
  @override
  final bool isIsolated;
  @override
  final bool isReinitialized;
  @override
  final FutureOr<void> Function(
    Progress progress,
  ) initialize;
}
