import 'dart:async';
import 'dart:isolate';

import 'package:dependency_initializer/src/dependency_initialization_result.dart';
import 'package:dependency_initializer/src/dependency_initialization_process.dart';
import 'package:dependency_initializer/src/dependency_initialization_step.dart';

part '_isolate_controller.dart';
part '_prepare_resource.dart';

class DependencyInitializer<
    Process extends DependencyInitializationProcess<Result>, Result> {
  const DependencyInitializer({
    required this.process,
    required this.stepList,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    this.onSuccess,
    this.onError,
  });

  final Process process;
  final List<DependencyInitializationStep<Process>> stepList;
  final void Function(
    Completer<DependencyInitializaionResult<Result>> completer,
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

    final Completer<DependencyInitializaionResult<Result>> completer =
        Completer<DependencyInitializaionResult<Result>>();
    this.onStart?.call(
          completer,
        );
    Process process = this.process;
    DependencyInitializationStep<Process> currentStep = stepList.first;

    final _PrepareResource<Process> prepareResource =
        await this._prepareResource();
    final _IsolateController? isolateController =
        prepareResource.isolateController;
    isolateController?.receivePort.listen(
      (
        dynamic message,
      ) {
        if (message is! Process) {
          return;
        }

        process = message;
      },
    );
    final List<DependencyInitializationStep<Process>> reInitializationStepList =
        prepareResource.reInitializationStepList;

    try {
      for (final DependencyInitializationStep<Process> step in this.stepList) {
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();

        currentStep = step;
        if (step.isIsolated) {
          isolateController?.send(
            process: process,
            step: step,
          );
        } else {
          await step.initialize(
            process,
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
      stopwatch.stop();
      isolateController?.close();

      this.onError?.call(
            error,
            stackTrace,
            process,
            currentStep,
            stopwatch.elapsed,
          );
      rethrow;
    }

    isolateController?.close();
    final Result result = process.toResult();
    completer.complete(
      DependencyInitializaionResult<Result>(
        result: result,
        reinitialization: () async {
          assert(
            completer.isCompleted,
            "Previos initializion process is not completed",
          );

          final Completer<Result> reCompleter = Completer<Result>();
          await DependencyInitializer(
            process: this.process,
            stepList: reInitializationStepList,
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
        },
      ),
    );
    stopwatch.stop();

    this.onSuccess?.call(
          result,
          stopwatch.elapsed,
        );
  }

  Future<_PrepareResource<Process>> _prepareResource() async {
    _IsolateController? isolateController;
    final List<DependencyInitializationStep<Process>> reInitializationStepList =
        [];

    for (final DependencyInitializationStep<Process> step in this.stepList) {
      if (step.isIsolated) {
        isolateController ??= await _IsolateController.spawn();
      }
      if (step.isReinitialized) {
        reInitializationStepList.add(
          step,
        );
      }
    }

    return _PrepareResource<Process>(
      isolateController: isolateController,
      reInitializationStepList: reInitializationStepList,
    );
  }
}
