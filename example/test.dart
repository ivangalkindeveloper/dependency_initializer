import 'dart:async';
import 'dart:isolate';

void main() async {
  final controller = IsolateController();
  await controller.startIsolate();

  controller.sendTask('Задача 1');
  controller.sendTask('Задача 2');

  await Future.delayed(Duration(seconds: 5));
  controller.close();
}

class IsolateController {
  late Isolate _isolate;
  late SendPort _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  IsolateController();

  Future<void> startIsolate() async {
    _isolate = await Isolate.spawn(_isolateEntry, _receivePort.sendPort);

    // Получаем SendPort из изолята
    _sendPort = await _receivePort.first as SendPort;

    // Слушаем сообщения из изолята
    _receivePort.listen((message) {
      print('Получено сообщение от изолята: $message');
    });
  }

  static void _isolateEntry(SendPort initialReplyTo) {
    final receivePort = ReceivePort();
    initialReplyTo.send(receivePort.sendPort);

    receivePort.listen((message) {
      // Выполняем задачу и отправляем ответ обратно
      print('Выполняется: $message');
      // Отправляем ответ обратно в главный изолят
      initialReplyTo.send('Завершено: $message');
    });
  }

  void sendTask(String task) {
    _sendPort.send(task);
  }

  void close() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }
}
