import 'package:example/core/dependency.dart';
import 'package:flutter/material.dart';

class Application extends StatelessWidget {
  const Application({super.key, required this.dependency});

  final Dependency dependency;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Error Screen")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text(dependency.initialCatFact.fact)),
        ),
      ),
    );
  }
}
