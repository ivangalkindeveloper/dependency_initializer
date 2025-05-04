import '../core/config.dart';

abstract interface class HttpClient {
  const HttpClient();

  abstract final Config config;
}

final class MyHttpClient implements HttpClient {
  const MyHttpClient({
    required this.config,
  });

  @override
  final Config config;
}
