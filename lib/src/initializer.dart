import 'dart:async';

import 'package:initializer/src/initialization_process.dart';
import 'package:initializer/src/initialization_step.dart';

class Initializer<Process extends InitializationProcess<Result>, Result> {
  const Initializer({
    required this.process,
    required this.stepList,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    required this.onSuccess,
    this.onError,
  });

  final Process process;
  final List<InitializationStep<Process>> stepList;
  final void Function(
    Completer<Result> completer,
    List<InitializationStep<Process>> stepList,
  )? onStart;
  final void Function(
    InitializationStep<Process> step,
  )? onStartStep;
  final void Function(
    InitializationStep<Process> step,
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
  )? onError;

  Future<void> run() async {
    assert(
      stepList.isNotEmpty,
      "Step list can't be empty",
    );

    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    final Completer<Result> completer = Completer<Result>();
    this.onStart?.call(
          completer,
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
      completer.completeError(
        error,
        stackTrace,
      );
      this.onError?.call(
            error,
            stackTrace,
            process,
            currentStep,
          );
      rethrow;
    }

    final Result result = process.toResult();
    completer.complete(
      result,
    );
    stopwatch.stop();

    this.onSuccess(
      result,
      stopwatch.elapsed,
    );
  }
}
