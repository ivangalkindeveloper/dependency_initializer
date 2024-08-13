import 'dart:async';

abstract class InitializationStep<Process> {
  abstract final String title;
  abstract final FutureOr<void> Function(
    Process progress,
  ) initialize;
}

class DefaultInitializationStep<Progress>
    implements InitializationStep<Progress> {
  const DefaultInitializationStep({
    required this.title,
    required this.initialize,
  });

  @override
  final String title;
  @override
  final FutureOr<void> Function(
    Progress progress,
  ) initialize;
}
