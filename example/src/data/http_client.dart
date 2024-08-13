import '../core/config.dart';

abstract interface class HttpClient {
  const HttpClient();

  abstract final Config config;
}

final class HttpClient$ implements HttpClient {
  const HttpClient$({
    required this.config,
  });

  @override
  final Config config;
}
