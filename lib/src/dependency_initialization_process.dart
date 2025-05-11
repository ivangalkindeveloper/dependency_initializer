/// Abstract class that represents a dependency initialization process.
///
/// This class defines the contract for creating a container from isolated results
/// during the dependency initialization process.
abstract class DependencyInitializationProcess<T> {
  const DependencyInitializationProcess();

  /// Converts isolated results into a container of type [T].
  ///
  /// [isolatedResults] - A map containing the results of isolated initialization steps.
  /// Returns a container of type [T] that contains all initialized dependencies.
  T toContainer(Map<dynamic, dynamic> isolatedResults);
}
