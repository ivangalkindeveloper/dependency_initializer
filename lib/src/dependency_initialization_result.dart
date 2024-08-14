final class DependencyInitializaionResult<Result> {
  const DependencyInitializaionResult({
    required this.result,
    required this.reinitialization,
  });

  final Result result;
  final Future<Result> Function() reinitialization;
}
