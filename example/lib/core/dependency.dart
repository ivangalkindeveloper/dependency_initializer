import 'package:example/core/domain.dart';
import 'package:example/core/data.dart';

final class Dependency {
  const Dependency({
    required this.environment,
    required this.repository,
    required this.initialCatFact,
  });

  final Environment environment;
  final Repository repository;
  final CatFact initialCatFact;
}
