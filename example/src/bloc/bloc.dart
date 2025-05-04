import '../data/repository.dart';

final class MyBloc {
  const MyBloc({
    required Repository repository,
  }) : this._repository = repository;

  // ignore: unused_field
  final Repository _repository;
}
