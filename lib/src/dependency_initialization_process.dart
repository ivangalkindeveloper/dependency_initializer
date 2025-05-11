abstract class DependencyInitializationProcess<T> {
  const DependencyInitializationProcess();

  T toContainer(Map<dynamic, dynamic> isolatedResults);
}
