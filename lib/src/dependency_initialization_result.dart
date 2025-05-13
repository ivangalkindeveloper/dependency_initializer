import 'package:dependency_initializer/dependency_initializer.dart';

/// Represents the result of a dependency initialization process.
///
/// This class contains the final container with initialized dependencies,
/// isolated results from initialization steps, and functions for repeating
/// the initialization process if needed.
final class DependencyInitializationResult<Process extends DIProcess, T> {
  const DependencyInitializationResult({
    required this.container,
    required this.isolatedResults,
    required this.repeatSteps,
    required this.runRepeat,
  });

  /// The final container containing all initialized dependencies.
  final T container;

  /// Map containing results from isolated initialization steps.
  final Map<dynamic, dynamic> isolatedResults;

  /// List of steps that can be repeated if needed.
  final List<DependencyInitializationStep> repeatSteps;

  /// Function to run the repeat process with the same or modified steps.
  final DIRepeatCallback<Process, T> runRepeat;
}
