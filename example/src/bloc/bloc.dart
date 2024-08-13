import '../data/repository.dart';

final class Bloc {
  const Bloc({
    required Repository repository,
  }) : this._repository = repository;

  // ignore: unused_field
  final Repository _repository;
}
