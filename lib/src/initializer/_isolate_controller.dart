part of 'dependency_initializer.dart';

final class _IsolateController<Process> {
  const _IsolateController({
    required this.isolate,
    required this.sendPort,
  });

  final Isolate isolate;
  final SendPort sendPort;

  static Future<_IsolateController<Process>> spawn<Process>({
    required bool errorsAreFatal,
    required String? debugName,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate = await Isolate.spawn(
      _entry<Process>,
      receivePort.sendPort,
      errorsAreFatal: errorsAreFatal,
      debugName: debugName,
    );
    final SendPort sendPort = await receivePort.first;
    receivePort.close();

    return _IsolateController(
      isolate: isolate,
      sendPort: sendPort,
    );
  }

  static void _entry<Process>(
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

  Future<Process> send({
    required Process process,
    required DependencyInitializationStep<Process> step,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    this.sendPort.send(
          _IsolateIteration(
            sendPort: receivePort.sendPort,
            process: process,
            step: step,
          ),
        );

    return await receivePort.first;
  }

  void close() => this.isolate.kill(
        priority: Isolate.immediate,
      );
}
