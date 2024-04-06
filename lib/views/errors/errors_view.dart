import 'package:flutter/material.dart';

class ErrorsView extends StatefulWidget {
  const ErrorsView({super.key});

  @override
  State<ErrorsView> createState() => _ErrorsViewState();
}

class _ErrorsViewState extends State<ErrorsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ERROS"),
      ),
    );;
  }
}
