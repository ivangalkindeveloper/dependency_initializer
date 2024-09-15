import 'dart:async';

sealed class DependencyInitializationStep<Process> {
  abstract final String? title;
  abstract final bool isIsolated;
  abstract final FutureOr<void> Function(
    Process progress,
  ) initialize;
}

class InitializationStep<Progress>
    implements DependencyInitializationStep<Progress> {
  const InitializationStep({
    this.title,
    this.isIsolated = false,
    required this.initialize,
  });

  @override
  final String? title;
  @override
  final bool isIsolated;
  @override
  final FutureOr<void> Function(
    Progress progress,
  ) initialize;
}

class ReInitializationStep<Progress>
    implements DependencyInitializationStep<Progress> {
  const ReInitializationStep({
    this.title,
    this.isIsolated = false,
    required this.initialize,
  });

  @override
  final String? title;
  @override
  final bool isIsolated;
  @override
  final FutureOr<void> Function(
    Progress progress,
  ) initialize;
}
