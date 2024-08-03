import 'package:initializer/src/initialization_progress.dart';
import 'package:initializer/src/initialization_step.dart';

class Initializer<Config, Progress extends InitializationProgress<Result>,
    Result> {
  const Initializer({
    required this.progress,
    required this.stepList,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    required this.onSuccess,
    this.onErrorStep,
  });

  final Progress progress;
  final List<InitializationStep<Progress>> stepList;
  final void Function(
    List<InitializationStep> stepList,
  )? onStart;
  final void Function(
    InitializationStep step,
  )? onStartStep;
  final void Function(
    InitializationStep step,
    Duration duration,
  )? onSuccessStep;
  final void Function(
    Result result,
    Duration duration,
  ) onSuccess;
  final void Function(
    InitializationStep<Progress> step,
    Object? error,
    StackTrace stackTrace,
  )? onErrorStep;

  Future<void> run() async {
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    InitializationStep<Progress> currentStep = stepList.first;
    this.onStart?.call(
          stepList,
        );

    try {
      for (final InitializationStep<Progress> step in this.stepList) {
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();
        currentStep = step;
        await step.initialize(
          progress,
        );
        stepStopWatch.stop();
        this.onSuccessStep?.call(
              step,
              stepStopWatch.elapsed,
            );
      }
    } catch (error, stackTrace) {
      this.onErrorStep?.call(
            currentStep,
            error,
            stackTrace,
          );
      rethrow;
    }

    stopwatch.stop();
    final Result result = progress.toResult();
    this.onSuccess(
      result,
      stopwatch.elapsed,
    );
  }
}
