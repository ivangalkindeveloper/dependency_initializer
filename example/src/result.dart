import 'bloc/bloc.dart';
import 'core/config.dart';
import 'data/repository.dart';

final class MyResult {
  const MyResult({
    required this.config,
    required this.repository,
    required this.bloc,
  });

  final Config config;
  final Repository repository;
  final MyBloc bloc;
}
