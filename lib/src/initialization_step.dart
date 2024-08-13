import 'dart:async';

abstract class InitializationStep<Process> {
  abstract final String title;
  abstract final FutureOr<void> Function(
    Process progress,
  ) initialize;
  abstract final bool isIsolated;
  abstract final bool isReinitialized;
}

class DefaultInitializationStep<Progress>
    implements InitializationStep<Progress> {
  const DefaultInitializationStep({
    required this.title,
    required this.initialize,
    this.isIsolated = false,
    this.isReinitialized = false,
  });

  @override
  final String title;
  @override
  final FutureOr<void> Function(
    Progress progress,
  ) initialize;
  @override
  final bool isIsolated;
  @override
  final bool isReinitialized;
}
