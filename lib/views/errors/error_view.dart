import 'package:flutter/material.dart';

class ErrorView extends StatefulWidget {
  const ErrorView({super.key});

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ERROS"),
      ),
      // body: ListView.separated(
      //   itemBuilder: itemBuilder,
      //   separatorBuilder: separatorBuilder,
      //   itemCount: itemCount,
      // ),
    );
  }
}
