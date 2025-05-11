part of 'dependency_initializer.dart';

/// Internal class that manages the execution of isolated initialization steps.
///
/// This class handles the creation and management of isolates for running
/// initialization steps in separate threads.
final class _IsolateController<Process extends DIProcess<T>, T> {
  _IsolateController({
    required this.onError,
  }) {
    _receivePort.listen(
      (
        dynamic message,
      ) async {
        final _Context<Process, T>? context = this.context;
        if (context == null || message is! _IsolateMessage) {
          return;
        }

        switch (message) {
          case _IsolateMessageSuccess():
            _completersById[message.id]?.complete();
            context.isolatedResults.addAll(
              message.result,
            );

          case _IsolateMessageError():
            if (context.error != null) {
              return;
            }

            _closeCompleters();
            context.catchError(
              message.error,
              message.stackTrace,
            );
            this.onError?.call(
                  message.error,
                  message.stackTrace,
                  context.process,
                  message.step,
                  context.stopwatch.elapsed,
                );
        }
      },
    );
  }

  /// The current initialization context.
  _Context<Process, T>? context;

  /// Callback function to handle errors during isolated step execution.
  final void Function(
    Object error,
    StackTrace stackTrace,
    Process process,
    DIStep step,
    Duration duration,
  )? onError;

  /// Port for receiving messages from isolates.
  final ReceivePort _receivePort = ReceivePort();

  /// Map of completers for tracking the completion of isolated steps.
  final Map<int, Completer<void>> _completersById = {};

  /// Synchronizes the context with the isolate controller.
  void syncContext({
    required _Context<Process, T> context,
  }) =>
      this.context = context;

  /// Executes all isolated initialization steps in separate isolates.
  ///
  /// Creates a new isolate for each step and waits for all steps to complete.
  Future<void> executeSteps() async {
    final _Context<Process, T>? context = this.context;
    if (context == null) {
      return Future.value();
    }

    _completersById.clear();

    final List<Future> isolates = List.generate(
      context.isolatedSteps.length,
      (
        index,
      ) {
        final IsolatedInitializationStep<Process, T, dynamic, dynamic> step =
            context.isolatedSteps[index];
        _completersById[step.hashCode] = Completer<void>();
        return Isolate.spawn<_IsolateRequest<Process, T, dynamic, dynamic>>(
          _entry<Process, T>,
          _IsolateRequest(
            id: step.hashCode,
            sendPort: _receivePort.sendPort,
            process: context.process,
            step: step,
          ),
          errorsAreFatal: step.errorsAreFatal,
          debugName: step.debugName,
        );
      },
    );

    await Future.wait(
      [
        Future.wait(isolates),
        ..._completersById.values.map(
          (
            Completer<void> completer,
          ) =>
              completer.future,
        ),
      ],
    );
  }

  /// Entry point for isolated initialization steps.
  ///
  /// Runs the initialization step in a separate isolate and sends the result
  /// back through the send port.
  static void _entry<Process extends DIProcess<T>, T>(
    _IsolateRequest<Process, T, dynamic, dynamic> request,
  ) async {
    try {
      final dynamic isolatedResult = await request.step.run(
        request.process,
      );
      request.sendPort.send(
        _IsolateMessageSuccess(
          id: request.id,
          result: {
            request.step.isolatedKey: isolatedResult,
          },
        ),
      );
    } catch (error, stackTrace) {
      request.sendPort.send(
        _IsolateMessageError(
          id: request.id,
          error: error,
          stackTrace: stackTrace,
          step: request.step,
        ),
      );
    }
  }

  /// Closes all pending completers.
  void _closeCompleters() {
    for (final Completer completer in _completersById.values) {
      if (completer.isCompleted) {
        continue;
      }
      completer.complete();
    }
  }

  /// Closes the isolate controller and cleans up resources.
  void close() {
    context = null;
    _receivePort.close();
    _closeCompleters();
    _completersById.clear();
  }
}
