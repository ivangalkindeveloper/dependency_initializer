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
    Completer<DependencyInitializaionResult<Process, Result>> completer,
  )? onStart;
  final void Function(
    DependencyInitializationStep<Process> step,
  )? onStartStep;
  final void Function(
    DependencyInitializationStep<Process> step,
    Duration duration,
  )? onSuccessStep;
  final void Function(
    Result result,
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

    final Completer<DependencyInitializaionResult<Process, Result>> completer =
        Completer<DependencyInitializaionResult<Process, Result>>();
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
    completer.complete(
      DependencyInitializaionResult<Process, Result>(
        result: result,
        reinitializationStepList: reinitializationStepList,
        reinitialization: this._reinitialization(
          completer: completer,
          result: result,
        ),
      ),
    );
    stopwatch.stop();
    this.onSuccess?.call(
          result,
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
      if (step.isReinitialized) {
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

  Future<Result> Function({
    required List<DependencyInitializationStep<Process>> stepList,
  }) _reinitialization({
    required Completer<DependencyInitializaionResult<Process, Result>>
        completer,
    required Result result,
  }) =>
      ({
        required List<DependencyInitializationStep<Process>> stepList,
      }) async {
        assert(
          completer.isCompleted,
          "Previos initialization process is not completed",
        );

        final Completer<Result> reCompleter = Completer<Result>();
        await DependencyInitializer(
          process: this.process,
          stepList: stepList,
          isolateErrorsAreFatal: this.isolateErrorsAreFatal,
          isolateDebugName: this.isolateDebugName,
          onStart: this.onStart,
          onStartStep: this.onStartStep,
          onSuccessStep: this.onSuccessStep,
          onSuccess: (
            Result result,
            Duration duration,
          ) =>
              reCompleter.complete(
            result,
          ),
          onError: (
            Object error,
            StackTrace stackTrace,
            Process process,
            DependencyInitializationStep<Process> step,
            Duration duration,
          ) =>
              reCompleter.completeError(
            error,
            stackTrace,
          ),
        ).run();

        return await reCompleter.future;
      };
}
