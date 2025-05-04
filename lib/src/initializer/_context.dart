part of 'dependency_initializer.dart';

/// Inner class that stores dependency initialization context.
///
/// This class contains an isolation controller for performing isolated initialization steps
/// and a list of steps that can be re-executed if necessary.
final class _Context<Process extends DIProcess<Result>, Result> {
  /// Creates a new [_Context] instance.
  ///
  /// [isolateController] - an isolation controller for executing isolated steps.
  /// [reinitializationStepList] - a list of steps that can be re-executed.
  const _Context({
    required this.isolateController,
    required this.reinitializationStepList,
  });

  /// Isolation controller for performing isolated initialization steps.
  ///
  /// If null, then there are no steps that require isolation.
  final _IsolateController<Process, Result>? isolateController;

  /// List of steps that can be re-executed.
  ///
  /// These steps are used when dependencies need to be reinitialized,
  /// for example when the environment changes.
  final List<DIStep<Process>> reinitializationStepList;
}
