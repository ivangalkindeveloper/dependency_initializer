import 'dart:async';
import 'dart:isolate';

import 'package:dependency_initializer/src/dependency_initialization_result.dart';
import 'package:dependency_initializer/src/dependency_initialization_process.dart';
import 'package:dependency_initializer/src/dependency_initialization_step.dart';

part '_context.dart';
part '_isolate_controller.dart';
part '_isolate_iteration.dart';

class DependencyInitializer<
    Process extends DependencyInitializationProcess<Result>, Result> {
  const DependencyInitializer({
    required this.process,
    required this.stepList,
    this.isolateErrorsAreFatal = true,
    this.isolateDebugName,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    this.onSuccess,
    this.onError,
  });

  final Process process;
  final List<DependencyInitializationStep<Process>> stepList;
  final bool isolateErrorsAreFatal;
  final String? isolateDebugName;
  final void Function(
    Completer<DependencyInitializationResult<Process, Result>> completer,
  )? onStart;
  final void Function(
    DependencyInitializationStep<Process> step,
  )? onStartStep;
  final void Function(
    DependencyInitializationStep<Process> step,
    Duration duration,
  )? onSuccessStep;
  final void Function(
    DependencyInitializationResult<Process, Result> result,
    Duration duration,
  )? onSuccess;
  final void Function(
    Object error,
    StackTrace stackTrace,
    Process process,
    DependencyInitializationStep<Process> step,
    Duration duration,
  )? onError;

  Future<void> run() async {
    assert(
      stepList.isNotEmpty,
      "Step list can't be empty",
    );

    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    final Completer<DependencyInitializationResult<Process, Result>> completer =
        Completer<DependencyInitializationResult<Process, Result>>();
    this.onStart?.call(
          completer,
        );
    Process currentProcess = this.process;
    DependencyInitializationStep<Process> currentStep = this.stepList.first;

    final _Context<Process, Result> context = await this._getContext();
    final _IsolateController<Process, Result>? isolateController =
        context.isolateController;
    final List<DependencyInitializationStep<Process>> reinitializationStepList =
        context.reinitializationStepList;

    try {
      for (final DependencyInitializationStep<Process> step in this.stepList) {
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();

        currentStep = step;
        if (step.isIsolated) {
          currentProcess = await isolateController?.send(
            process: currentProcess,
            step: step,
          ) as Process;
        } else {
          await step.initialize(
            currentProcess,
          );
        }

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
      isolateController?.close();
      stopwatch.stop();
      this.onError?.call(
            error,
            stackTrace,
            currentProcess,
            currentStep,
            stopwatch.elapsed,
          );
      rethrow;
    }

    isolateController?.close();
    final Result result = currentProcess.toResult();
    final DependencyInitializationResult<Process, Result> initializationResult =
        DependencyInitializationResult<Process, Result>(
      result: result,
      reinitializationStepList: reinitializationStepList,
      reRun: this._reRun(
        completer: completer,
        result: result,
        reinitializationStepList: reinitializationStepList,
      ),
    );
    completer.complete(
      initializationResult,
    );
    stopwatch.stop();
    this.onSuccess?.call(
          initializationResult,
          stopwatch.elapsed,
        );
  }

  Future<_Context<Process, Result>> _getContext() async {
    _IsolateController<Process, Result>? isolateController;
    final List<DependencyInitializationStep<Process>> reinitializationStepList =
        [];

    for (final DependencyInitializationStep<Process> step in this.stepList) {
      if (step.isIsolated) {
        isolateController ??= await _IsolateController.spawn<Process, Result>(
          errorsAreFatal: this.isolateErrorsAreFatal,
          debugName: this.isolateDebugName,
        );
      }
      if (step is ReInitializationStep) {
        reinitializationStepList.add(
          step,
        );
      }
    }

    return _Context<Process, Result>(
      isolateController: isolateController,
      reinitializationStepList: reinitializationStepList,
    );
  }

  Future<void> Function({
    required Process process,
    List<DependencyInitializationStep<Process>>? stepList,
    void Function(
      Completer<DependencyInitializationResult<Process, Result>> completer,
    )? onStart,
    void Function(
      DependencyInitializationStep<Process> step,
    )? onStartStep,
    void Function(
      DependencyInitializationStep<Process> step,
      Duration duration,
    )? onSuccessStep,
    void Function(
      DependencyInitializationResult<Process, Result> result,
      Duration duration,
    )? onSuccess,
    void Function(
      Object error,
      StackTrace stackTrace,
      Process process,
      DependencyInitializationStep<Process> step,
      Duration duration,
    )? onError,
  }) _reRun({
    required Completer<DependencyInitializationResult<Process, Result>>
        completer,
    required Result result,
    required List<DependencyInitializationStep<Process>>
        reinitializationStepList,
  }) =>
      ({
        required Process process,
        List<DependencyInitializationStep<Process>>? stepList,
        void Function(
          Completer<DependencyInitializationResult<Process, Result>> completer,
        )? onStart,
        void Function(
          DependencyInitializationStep<Process> step,
        )? onStartStep,
        void Function(
          DependencyInitializationStep<Process> step,
          Duration duration,
        )? onSuccessStep,
        void Function(
          DependencyInitializationResult<Process, Result> result,
          Duration duration,
        )? onSuccess,
        void Function(
          Object error,
          StackTrace stackTrace,
          Process process,
          DependencyInitializationStep<Process> step,
          Duration duration,
        )? onError,
      }) async {
        assert(
          completer.isCompleted,
          "Previos initialization process is not completed",
        );

        await DependencyInitializer(
          process: process,
          stepList: stepList ?? reinitializationStepList,
          isolateErrorsAreFatal: this.isolateErrorsAreFatal,
          isolateDebugName: this.isolateDebugName,
          onStart: onStart ?? this.onStart,
          onStartStep: onStartStep ?? this.onStartStep,
          onSuccessStep: onSuccessStep ?? this.onSuccessStep,
          onSuccess: onSuccess ?? this.onSuccess,
          onError: onError ?? this.onError,
        ).run();
      };
}
