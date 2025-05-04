import 'dart:async';
import 'dart:isolate';

import 'package:dependency_initializer/src/dependency_initialization_step.dart';
import 'package:dependency_initializer/src/typedef.dart';

part '_context.dart';
part '_isolate_controller.dart';
part '_isolate_iteration.dart';

/// DependencyInitializer is a convenient and understandable contract for initializing dependencies for further use.
/// The main goal of this utility is to provide a clear assembly of a dependency container with initialization steps.
// Advantages:
/// 1) Convenient configuration - creating your own initialization steps and filling the initialization process;
/// 2) Error handling and providing initialization indicators;
/// 3) Re-initialization for steps that were created as repeated, for example, for changing the environment.
class DependencyInitializer<Process extends DIProcess<Result>, Result> {
  /// Creates a new instance of [DependencyInitializer].
  ///
  /// [createProcess] — function for creating initialization process.
  /// [stepList] — list of initialization steps.
  /// [isolateErrorsAreFatal] — flag that determines whether errors in isolate are fatal.
  /// [isolateDebugName] — name for debugging isolate.
  /// [onStart] — callback that is called when initialization starts.
  /// [onStartStep] — callback that is called when a step starts.
  /// [onSuccessStep] — callback that is called when a step is successfully completed.
  /// [onSuccess] — callback that is called when initialization is successful.
  /// [onError] — callback that is called when an error occurs.
  const DependencyInitializer({
    required this.createProcess,
    required this.stepList,
    this.isolateErrorsAreFatal = true,
    this.isolateDebugName,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    this.onSuccess,
    this.onError,
  });

  /// Function to create a new initialization process.
  final Process Function() createProcess;

  /// List of initialization steps.
  final List<DIStep<Process>> stepList;

  /// Flag that determines whether errors in isolate are fatal.
  final bool isolateErrorsAreFatal;

  /// Name for debugging isolate.
  final String? isolateDebugName;

  /// Callback that is called when initialization starts.
  final void Function(
    Completer<DIResult<Process, Result>> completer,
  )? onStart;

  /// Callback that is called when a step starts.
  final void Function(
    DIStep<Process> step,
  )? onStartStep;

  /// Callback that is called when a step is successfully completed.
  final void Function(
    DIStep<Process> step,
    Duration duration,
  )? onSuccessStep;

  /// Callback that is called when initialization is successful.
  final void Function(
    DIResult<Process, Result> result,
    Duration duration,
  )? onSuccess;

  /// Callback that is called when an error occurs.
  final void Function(
    Object error,
    StackTrace stackTrace,
    Process process,
    DIStep<Process> step,
    Duration duration,
  )? onError;

  /// Starts the dependency initialization process.
  ///
  /// May throw an error if any step fails.
  Future<void> run() async {
    assert(
      stepList.isNotEmpty,
      "Step list can't be empty",
    );

    final Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    final Completer<DIResult<Process, Result>> completer =
        Completer<DIResult<Process, Result>>();
    this.onStart?.call(
          completer,
        );
    Process currentProcess = this.createProcess();
    DIStep<Process> currentStep = this.stepList.first;

    final _Context<Process, Result> context = await this._getContext();
    final _IsolateController<Process, Result>? isolateController =
        context.isolateController;

    try {
      for (final DIStep<Process> step in this.stepList) {
        currentStep = step;
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();

        if (step.isIsolated && isolateController != null) {
          currentProcess = await isolateController.send(
            process: currentProcess,
            step: step,
          );
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
    final List<DIStep<Process>> reinitializationStepList =
        context.reinitializationStepList;
    final DIResult<Process, Result> initializationResult =
        DIResult<Process, Result>(
      result: result,
      reinitializationStepList: reinitializationStepList,
      repeat: this._repeat(
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

  /// Internal method for getting the initialization context.
  ///
  /// Returns [_Context] containing the isolate controller and the list of steps to reinitialize.
  Future<_Context<Process, Result>> _getContext() async {
    _IsolateController<Process, Result>? isolateController;
    final List<DIStep<Process>> reinitializationStepList = [];

    for (final DIStep<Process> step in this.stepList) {
      if (step.isIsolated) {
        isolateController ??= await _IsolateController.spawn<Process, Result>(
          errorsAreFatal: this.isolateErrorsAreFatal,
          debugName: this.isolateDebugName,
        );
      }

      switch (step) {
        case InitializationStep<Process>():
          break;

        case RepeatInitializationStep<Process>():
          reinitializationStepList.add(
            step,
          );
          break;
      }
    }

    return _Context<Process, Result>(
      isolateController: isolateController,
      reinitializationStepList: reinitializationStepList,
    );
  }

  /// Returns a function to re-run the initialization process.
  ///
  /// Used to reinitialize dependencies, for example when changing the environment.
  Future<void> Function({
    Process Function()? createProcess,
    List<DIStep<Process>>? stepList,
    void Function(
      Completer<DIResult<Process, Result>> completer,
    )? onStart,
    void Function(
      DIStep<Process> step,
    )? onStartStep,
    void Function(
      DIStep<Process> step,
      Duration duration,
    )? onSuccessStep,
    void Function(
      DIResult<Process, Result> result,
      Duration duration,
    )? onSuccess,
    void Function(
      Object error,
      StackTrace stackTrace,
      Process process,
      DIStep<Process> step,
      Duration duration,
    )? onError,
  }) _repeat({
    required Completer<DIResult<Process, Result>> completer,
    required Result result,
    required List<DIStep<Process>> reinitializationStepList,
  }) =>
      ({
        Process Function()? createProcess,
        List<DIStep<Process>>? stepList,
        void Function(
          Completer<DIResult<Process, Result>> completer,
        )? onStart,
        void Function(
          DIStep<Process> step,
        )? onStartStep,
        void Function(
          DIStep<Process> step,
          Duration duration,
        )? onSuccessStep,
        void Function(
          DIResult<Process, Result> result,
          Duration duration,
        )? onSuccess,
        void Function(
          Object error,
          StackTrace stackTrace,
          Process process,
          DIStep<Process> step,
          Duration duration,
        )? onError,
      }) async {
        assert(
          completer.isCompleted,
          "Previos initialization process is not completed",
        );

        await DependencyInitializer(
          createProcess: createProcess ?? this.createProcess,
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
