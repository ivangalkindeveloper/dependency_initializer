part of 'dependency_initializer.dart';

/// Inner class that manages the lifecycle of an isolate for dependency initialization.
///
/// This class is responsible for creating and managing an isolate that can execute
/// initialization steps in isolation from the main isolate.
final class _IsolateController<Process extends DIProcess<Result>, Result> {
  /// Creates a new [_IsolateController] instance.
  ///
  /// [isolate] - the isolate instance to be controlled.
  /// [sendPort] - port for sending messages to the isolate.
  const _IsolateController._({
    required this.isolate,
    required this.sendPort,
  });

  /// The isolate instance being controlled.
  final Isolate isolate;

  /// Port for sending messages to the isolate.
  final SendPort sendPort;

  /// Spawns a new isolate and returns a controller for it.
  ///
  /// [errorsAreFatal] - whether errors in the isolate should be fatal.
  /// [debugName] - optional name for debugging purposes.
  static Future<_IsolateController<Process, Result>>
      spawn<Process extends DIProcess<Result>, Result>({
    required bool errorsAreFatal,
    required String? debugName,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate = await Isolate.spawn(
      _entry<Process, Result>,
      receivePort.sendPort,
      errorsAreFatal: errorsAreFatal,
      debugName: debugName,
    );
    final SendPort sendPort = await receivePort.first;
    receivePort.close();

    return _IsolateController._(
      isolate: isolate,
      sendPort: sendPort,
    );
  }

  /// Entry point for the isolate.
  ///
  /// Sets up message handling for initialization steps in the isolate.
  static void _entry<Process extends DIProcess<Result>, Result>(
    SendPort initializerSendPort,
  ) {
    final ReceivePort receivePort = ReceivePort();
    initializerSendPort.send(
      receivePort.sendPort,
    );
    receivePort.listen(
      (
        dynamic message,
      ) async {
        if (message is! _IsolateIteration<Process>) {
          return;
        }

        await message.step.initialize(
          message.process,
        );

        message.sendPort.send(
          message.process,
        );
      },
    );
  }

  /// Sends an initialization step to be executed in the isolate.
  ///
  /// [process] - the current state of the initialization process.
  /// [step] - the initialization step to be executed.
  /// Returns the updated process state after step execution.
  Future<Process> send({
    required Process process,
    required DIStep<Process> step,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    this.sendPort.send(
          _IsolateIteration<Process>(
            sendPort: receivePort.sendPort,
            process: process,
            step: step,
          ),
        );

    return await receivePort.first;
  }

  /// Closes the isolate and releases its resources.
  void close() => this.isolate.kill(
        priority: Isolate.immediate,
      );
}
