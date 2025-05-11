part of 'dependency_initializer.dart';

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

  _Context<Process, T>? context;
  final void Function(
    Object error,
    StackTrace stackTrace,
    Process process,
    DIStep step,
    Duration duration,
  )? onError;
  final ReceivePort _receivePort = ReceivePort();
  final Map<int, Completer<void>> _completersById = {};

  void syncContext({
    required _Context<Process, T> context,
  }) =>
      this.context = context;

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

  void _closeCompleters() {
    for (final Completer completer in _completersById.values) {
      if (completer.isCompleted) {
        continue;
      }
      completer.complete();
    }
  }

  void close() {
    context = null;
    _receivePort.close();
    _closeCompleters();
    _completersById.clear();
  }
}
