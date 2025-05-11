import 'package:flutter/material.dart';

class ErrorApplication extends StatelessWidget {
  const ErrorApplication({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Error Screen")),
        body: Center(child: Text(error.toString())),
      ),
    );
  }
}
