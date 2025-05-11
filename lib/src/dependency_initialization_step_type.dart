/// Enum representing the type of a dependency initialization step.
///
/// This enum defines different types of initialization steps that can be
/// performed during the dependency initialization process.
enum DependencyInitializationStepType {
  /// A simple step that runs once and completes.
  simple,

  /// A step that can be repeated multiple times if needed.
  repeatable;
}
