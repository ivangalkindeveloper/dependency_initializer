import 'http_client.dart';

abstract interface class Api {
  const Api();

  abstract final HttpClient client;
}

final class MyApi implements Api {
  const MyApi({
    required this.client,
  });

  @override
  final HttpClient client;
}
