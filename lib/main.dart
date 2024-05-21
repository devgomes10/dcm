import 'package:dcm/views/bluetooth_connection/connection_view.dart';
import 'package:dcm/views/indicators/indicators_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth App',
      initialRoute: '/',
      routes: {
        '/': (context) => const BluetoothScreen(),
        '/dataTransferPage': (context) => const IndicatorsView(),
      },
    );
  }
}
