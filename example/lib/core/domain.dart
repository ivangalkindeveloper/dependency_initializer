final class CatFact {
  const CatFact({required this.fact, required this.length});

  final String fact;
  final int length;

  factory CatFact.fromJson(Map<String, dynamic> json) =>
      CatFact(fact: json['fact'] as String, length: json['length'] as int);
}
