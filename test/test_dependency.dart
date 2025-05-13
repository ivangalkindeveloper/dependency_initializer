import 'test_data.dart';
import 'test_domain.dart';

final class Dependency {
  const Dependency({
    required this.environment,
    required this.repository,
    required this.initialCatFact0,
    required this.initialCatFact1,
    required this.initialCatFact2,
  });

  final Environment environment;
  final Repository repository;
  final CatFact? initialCatFact0;
  final CatFact? initialCatFact1;
  final CatFact? initialCatFact2;
}
