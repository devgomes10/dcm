import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:convert';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final TextEditingController textEditingController = TextEditingController();
  List<BluetoothDiscoveryResult> devicesList = [];
  BluetoothConnection? connection;
  String receivedMessages = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      if (state == BluetoothState.STATE_OFF) {
        FlutterBluetoothSerial.instance.requestEnable();
      }
    });
  }

  // Função para buscar dispositivos
  void searchDevices() async {
    setState(() {
      isSearching = true;
      devicesList.clear();
    });

    try {
      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        setState(() {
          devicesList.add(result);
        });
      }).onDone(() {
        setState(() {
          isSearching = false;
        });
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      // Exibir um alerta de erro
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Erro ao procurar dispositivos: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Função para conectar a um dispositivo
  void connectDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection newConnection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connection = newConnection;
      });
      connection!.input!.listen((Uint8List data) {
        setState(() {
          receivedMessages += String.fromCharCodes(data);
        });
      }).onDone(() {
        setState(() {
          connection = null;
        });
      });
    } catch (e) {
      setState(() {
        connection = null;
      });
      // Exibir um alerta de erro
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Erro ao conectar: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Função para enviar comando
  void sendCommand() {
    if (connection != null && connection!.isConnected) {
      String message = textEditingController.text;
      connection!.output.add(Uint8List.fromList(utf8.encode(message + '\r\n')));
      textEditingController.clear();
    }
  }

  // Função para retornar mensagens
  String returnMessages() {
    return receivedMessages;
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLUETOOTH"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isSearching ? null : searchDevices,
              child: Text(isSearching ? "Procurando..." : "Procurar"),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDiscoveryResult result = devicesList[index];
                return ListTile(
                  title: Text(result.device.name ?? "Dispositivo desconhecido"),
                  subtitle: Text(result.device.address),
                  onTap: () {
                    connectDevice(result.device);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  onPressed: sendCommand,
                  icon: const Icon(Icons.send),
                ),
                hintText: "Digite seu comando",
              ),
            ),
            const SizedBox(height: 16),
            Text(
              returnMessages(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
