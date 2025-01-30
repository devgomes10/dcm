import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';

class Signals extends StatefulWidget {
  const Signals({super.key});

  @override
  State<Signals> createState() => _SignalsState();
}

class _SignalsState extends State<Signals> {
  List<Map<String, dynamic>> _decodedSignals = [];

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  void _loadExcelData() async {
    var file = File('/path/to/Proposta1_editada2.xlsx').readAsBytesSync();
    var excel = Excel.decodeBytes(file);

    var mwmSheet = excel['MWM'];
    var normaSheet = excel['NormaEditada2'];

    // Process the sheets to extract and decode signals
    // Example: decoding logic to be implemented based on the structure of the sheets

    setState(() {
      // _decodedSignals = decodedSignals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sinais"),
      ),
      body: ListView.builder(
        itemCount: _decodedSignals.length,
        itemBuilder: (context, index) {
          var signal = _decodedSignals[index];
          return ListTile(
            title: Text(signal['SPN Name']),
            subtitle: Text(signal['Hex Value']),
          );
        },
      ),
    );
  }
}
