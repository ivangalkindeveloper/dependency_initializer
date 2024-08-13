import 'dart:async';
import 'dart:isolate';

import 'package:initializer/src/initialization_process.dart';
import 'package:initializer/src/initialization_step.dart';

class Initializer<Process extends InitializationProcess<Result>, Result> {
  const Initializer({
    required this.process,
    required this.stepList,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    this.onSuccess,
    this.onError,
  });

  final Process process;
  final List<InitializationStep<Process>> stepList;

  final void Function(
    Completer<
            (
              Result result,
              Future<void> Function() reinitialization,
            )>
        completer,
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
  )? onSuccess;
  final void Function(
    Object? error,
    StackTrace stackTrace,
    Process process,
    InitializationStep<Process> step,
    Duration duration,
  )? onError;

  Future<void> run() async {
    assert(
      stepList.isNotEmpty,
      "Step list can't be empty",
    );

    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    final Completer<(Result, Future<void> Function())> completer =
        Completer<(Result, Future<void> Function())>();
    this.onStart?.call(
          completer,
          stepList,
        );
    InitializationStep<Process> currentStep = stepList.first;

    final List<InitializationStep<Process>> reInitializationStepList = [];
    for (final InitializationStep<Process> step in this.stepList) {
      if (step.isReinitialized) {
        reInitializationStepList.add(
          step,
        );
      }
    }

    (
      SendPort,
      Isolate,
    )? isolateGroup;
    try {
      for (final InitializationStep<Process> step in this.stepList) {
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();

        currentStep = step;
        if (step.isIsolated) {
          isolateGroup ??= await _spawnIsolate();
          isolateGroup.$1.send(
            () async => step.initialize(
              process,
            ),
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
      isolateGroup?.$2.kill(
        priority: Isolate.immediate,
      );

      this.onError?.call(
            error,
            stackTrace,
            process,
            currentStep,
            stopwatch.elapsed,
          );
      rethrow;
    }

    isolateGroup?.$2.kill(
      priority: Isolate.immediate,
    );
    final Result result = process.toResult();
    completer.complete(
      (
        result,
        () async {
          assert(
            completer.isCompleted,
            "Previos initializion process is not completed",
          );

          await Initializer(
            process: this.process,
            stepList: reInitializationStepList,
            onStart: this.onStart,
            onStartStep: this.onStartStep,
            onSuccessStep: this.onSuccessStep,
            onSuccess: this.onSuccess,
            onError: this.onError,
          ).run();
        },
      ),
    );
    stopwatch.stop();

    this.onSuccess?.call(
          result,
          stopwatch.elapsed,
        );
  }

  Future<
      (
        SendPort,
        Isolate,
      )> _spawnIsolate() async {
    final ReceivePort initializerReceivePort = ReceivePort();
    final Isolate isolate = await Isolate.spawn(
      (
        SendPort sendPort,
      ) {
        final ReceivePort receivePort = ReceivePort();
        sendPort.send(
          receivePort.sendPort,
        );
        receivePort.listen(
          (
            dynamic message,
          ) async {
            if (message is! FutureOr<void> Function()) {
              return;
            }

            await message();
          },
        );
      },
      initializerReceivePort.sendPort,
    );

    final SendPort isolateSendPort = await initializerReceivePort.first;
    initializerReceivePort.close();

    return (
      isolateSendPort,
      isolate,
    );
  }
}
