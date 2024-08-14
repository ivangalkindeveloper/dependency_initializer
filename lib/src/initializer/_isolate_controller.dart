part of 'dependency_initializer.dart';

final class _IsolateController<Process> {
  _IsolateController({
    required this.isolate,
    required this.receivePort,
    required this.sendPort,
  });

  final Isolate isolate;
  final ReceivePort receivePort;
  final SendPort sendPort;

  static Future<_IsolateController> spawn<Process>() async {
    final ReceivePort initializerReceivePort = ReceivePort();
    final Isolate isolate = await Isolate.spawn(
      (
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
            if (message is! (
              Process,
              DependencyInitializationStep<Process>,
            )) {
              return;
            }

            await message.$2.initialize(
              message.$1,
            );

            initializerSendPort.send(
              message.$1,
            );
          },
        );
      },
      initializerReceivePort.sendPort,
    );

    final SendPort sendPort = await initializerReceivePort.first;

    return _IsolateController(
      isolate: isolate,
      receivePort: initializerReceivePort,
      sendPort: sendPort,
    );
  }

  void send({
    required Process process,
    required DependencyInitializationStep<Process> step,
  }) =>
      this.sendPort.send(
        (
          process,
          step,
        ),
      );

  void close() {
    this.isolate.kill(
          priority: Isolate.immediate,
        );
    this.receivePort.close();
  }
}
