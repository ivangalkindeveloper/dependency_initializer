import 'dart:async';
import 'dart:isolate';

import 'package:dependency_initializer/dependency_initializer.dart';

part '_context.dart';
part '_isolate_controller.dart';
part '_isolate_request.dart';
part '_isolate_message.dart';

/// DependencyInitializer is a convenient and understandable contract for initializing dependencies for further use.
/// The main goal of this utility is to provide a clear assembly of a dependency container with initialization steps.
///
/// Advantages:
/// 1) Convenient configuration - creating your own initialization steps and filling the initialization process;
/// 2) Error handling and providing initialization indicators;
/// 3) Re-initialization for steps that were created as repeated, for example, for changing the environment.
final class DependencyInitializer<Process extends DIProcess<T>, T> {
  /// Creates a new instance of [DependencyInitializer].
  ///
  /// [createProcess] — function for creating initialization process.
  /// [steps] — list of initialization steps.
  /// [onStart] — callback that is called when initialization starts.
  /// [onStartStep] — callback that is called when a step starts.
  /// [onSuccessStep] — callback that is called when a step is successfully completed.
  /// [onSuccess] — callback that is called when initialization is successful.
  /// [onError] — callback that is called when an error occurs.
  const DependencyInitializer({
    required this.createProcess,
    required this.steps,
    this.onStart,
    this.onStartStep,
    this.onSuccessStep,
    this.onSuccess,
    this.onError,
  });

  /// Function to create a new initialization process.
  final Process Function() createProcess;

  /// List of initialization steps.
  final List<DIStep> steps;

  /// Callback that is called when initialization starts.
  final void Function(
    Completer<DIResult<Process, T>> completer,
  )? onStart;

  /// Callback that is called when a step starts.
  final void Function(
    DIStep step,
  )? onStartStep;

  /// Callback that is called when a step is successfully completed.
  final void Function(
    DIStep step,
    Duration stepDuration,
    Duration duration,
  )? onSuccessStep;

  /// Callback that is called when initialization is successful.
  final void Function(
    DIResult<Process, T> result,
    Duration duration,
  )? onSuccess;

  /// Callback that is called when an error occurs.
  final void Function(
    Object error,
    StackTrace stackTrace,
    Process process,
    DIStep step,
    Duration duration,
  )? onError;

  /// Starts the dependency initialization process.
  ///
  /// May throw an error if any step fails.
  Future<void> run() async {
    assert(
      steps.isNotEmpty,
      "Step list can't be empty",
    );

    final _Context<Process, T> context = this._getContext();
    this.onStart?.call(
          context.completer,
        );

    this._executeSteps(
      context: context,
    );

    await this._executeIsolatedSteps(
      context: context,
    );
  }

  /// Creates and initializes the context for the initialization process.
  _Context<Process, T> _getContext() {
    final Process process = this.createProcess();
    final Completer<DIResult<Process, T>> completer =
        Completer<DIResult<Process, T>>();
    final Stopwatch stopwatch = Stopwatch();
    _IsolateController<Process, T>? isolateController;
    final Map<dynamic, dynamic> isolatedResults = {};
    final List<InitializationStep> steps = [];
    final List<IsolatedInitializationStep> isolatedSteps = [];
    final List<DIStep> repeatSteps = [];

    for (final DIStep step in this.steps) {
      switch (step) {
        case InitializationStep():
          steps.add(step);
          break;

        case IsolatedInitializationStep():
          isolateController ??= _IsolateController<Process, T>(
            onError: this.onError,
          );
          isolatedSteps.add(step);
          break;
      }

      switch (step.type) {
        case DIStepType.simple:
          break;

        case DIStepType.repeatable:
          repeatSteps.add(step);
          break;
      }
    }

    final _Context<Process, T> context = _Context<Process, T>(
      process: process,
      completer: completer,
      stopwatch: stopwatch,
      isolateController: isolateController,
      isolatedResults: isolatedResults,
      steps: steps.cast<InitializationStep<Process, T>>(),
      isolatedSteps: isolatedSteps
          .cast<IsolatedInitializationStep<Process, T, dynamic, dynamic>>(),
      repeatSteps: repeatSteps,
    );
    isolateController?.syncContext(
      context: context,
    );

    return context;
  }

  /// Executes regular initialization steps in the main isolate.
  Future<void> _executeSteps({
    required _Context<Process, T> context,
  }) async {
    if (context.steps.isEmpty) {
      return;
    }

    InitializationStep<Process, T> currentStep = context.steps.first;
    try {
      for (final InitializationStep<Process, T> step in context.steps) {
        final Stopwatch stepStopWatch = Stopwatch();
        stepStopWatch.start();

        await step.run(
          context.process,
        );

        stepStopWatch.stop();
        this.onSuccessStep?.call(
              step,
              stepStopWatch.elapsed,
              context.stopwatch.elapsed,
            );
      }

      if (context.isolatedSteps.isEmpty) {
        return this._executeSuccess(
          context: context,
        );
      }
    } catch (error, stackTrace) {
      context.catchError(
        error,
        stackTrace,
      );
      this.onError?.call(
            error,
            stackTrace,
            context.process,
            currentStep,
            context.stopwatch.elapsed,
          );
    }
  }

  /// Executes isolated initialization steps in separate isolates.
  Future<void> _executeIsolatedSteps({
    required _Context<Process, T> context,
  }) async {
    final _IsolateController<Process, T>? isolateController =
        context.isolateController;
    if (context.isolatedSteps.isEmpty ||
        isolateController == null ||
        context.error != null) {
      return;
    }

    await isolateController.executeSteps();
    this._executeSuccess(
      context: context,
    );
  }

  /// Handles successful completion of the initialization process.
  void _executeSuccess({
    required _Context<Process, T> context,
  }) {
    if (context.error != null) {
      return;
    }

    final DIResult<Process, T> result = DIResult<Process, T>(
      container: context.process.toContainer(context.isolatedResults),
      isolatedResults: context.isolatedResults,
      repeatSteps: context.repeatSteps,
      runRepeat: this._runRepeat(
        context: context,
      ),
    );
    context.finish(
      result,
    );
    this.onSuccess?.call(
          result,
          context.stopwatch.elapsed,
        );
  }

  /// Creates a function for repeating the initialization process.
  DIRepeatFunction<Process, T> _runRepeat({
    required _Context<Process, T> context,
  }) =>
      ({
        Process Function()? createProcess,
        List<DIStep>? steps,
        void Function(
          Completer<DIResult<Process, T>> completer,
        )? onStart,
        void Function(
          DIStep step,
        )? onStartStep,
        void Function(
          DIStep step,
          Duration stepDuration,
          Duration duration,
        )? onSuccessStep,
        void Function(
          DIResult<Process, T> result,
          Duration duration,
        )? onSuccess,
        void Function(
          Object error,
          StackTrace stackTrace,
          Process process,
          DIStep step,
          Duration duration,
        )? onError,
      }) async =>
          DependencyInitializer<Process, T>(
            createProcess: createProcess ?? this.createProcess,
            steps: steps ?? context.repeatSteps,
            onStart: onStart ?? this.onStart,
            onStartStep: onStartStep ?? this.onStartStep,
            onSuccessStep: onSuccessStep ?? this.onSuccessStep,
            onSuccess: onSuccess ?? this.onSuccess,
            onError: onError ?? this.onError,
          ).run;
}
