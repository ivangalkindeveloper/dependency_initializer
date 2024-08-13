import 'bloc/bloc.dart';
import 'core/config.dart';
import 'data/repository.dart';

final class Result {
  const Result({
    required this.config,
    required this.repository,
    required this.bloc,
  });

  final Config config;
  final Repository repository;
  final Bloc bloc;
}
