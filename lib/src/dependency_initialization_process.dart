/// Abstract class that represents a process of dependency initialization.
///
/// This class serves as a base for creating custom dependency initialization processes.
/// It provides a way to convert the initialization process state into a final result.
abstract class DependencyInitializationProcess<Result> {
  /// Creates a new [DependencyInitializationProcess] instance.
  const DependencyInitializationProcess();

  /// Converts the current state of the initialization process into a final result.
  ///
  /// This method should be implemented to transform the accumulated state
  /// of the initialization process into the desired result type.
  Result toResult();
}
