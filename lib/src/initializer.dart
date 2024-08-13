import 'package:initializer/src/initialization_process.dart';
import 'package:initializer/src/initialization_step.dart';

class Initializer<Process extends InitializationProcess<Result>, Result> {
  Initializer({
    required this.process,
    required this.stepList,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    required this.onSuccess,
    this.onErrorStep,
  }) {
    assert(
      stepList.isNotEmpty,
      "Step list can't be empty",
    );
  }

  final Process process;
  final List<InitializationStep<Process>> stepList;
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
    Object? error,
    StackTrace stackTrace,
    Process process,
    InitializationStep<Process> step,
  )? onErrorStep;

  Future<void> run() async {
    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    this.onStart?.call(
          stepList,
        );
    InitializationStep<Process> currentStep = stepList.first;

    try {
      for (final InitializationStep<Process> step in this.stepList) {
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();
        currentStep = step;
        await step.initialize(
          process,
        );
        stepStopWatch.stop();
        this.onSuccessStep?.call(
              step,
              stepStopWatch.elapsed,
            );
      }
    } catch (error, stackTrace) {
      this.onErrorStep?.call(
            error,
            stackTrace,
            process,
            currentStep,
          );
      rethrow;
    }

    stopwatch.stop();
    final Result result = process.toResult();
    this.onSuccess(
      result,
      stopwatch.elapsed,
    );
  }
}
