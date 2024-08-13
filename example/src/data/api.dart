import 'http_client.dart';

abstract interface class Api {
  const Api();

  abstract final HttpClient client;
}

final class Api$ implements Api {
  const Api$({
    required this.client,
  });

  @override
  final HttpClient client;
}
