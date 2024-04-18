import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

class BluetoothConnectionView extends StatefulWidget {
  const BluetoothConnectionView({super.key});

  @override
  State<BluetoothConnectionView> createState() =>
      _BluetoothConnectionViewState();
}

class _BluetoothConnectionViewState extends State<BluetoothConnectionView> {
  final BluetoothClassic _bluetooth = BluetoothClassic();
  String _receivedData = '';
  TextEditingController sendDataController = TextEditingController();

  List<Device> _pairedDevices = [];
  List<Device> _discoveredDevices = [];

  bool _scanning = false;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    await _bluetooth.initPermissions();
    _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    List<Device> pairedDevices = await _bluetooth.getPairedDevices();
    setState(() {
      _pairedDevices = pairedDevices;
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _discoveredDevices = [];
    });

    _bluetooth.onDeviceDiscovered().listen((device) {
      setState(() {
        _discoveredDevices.add(device);
      });
    });

    await _bluetooth.startScan();
  }

  Future<void> _stopScan() async {
    await _bluetooth.stopScan();
    setState(() {
      _scanning = false;
    });
  }

  Future<void> _connectToDevice(Device device) async {
    await _bluetooth.connect(
      device.address,
      "",
    );

    _bluetooth.onDeviceDataReceived().listen((data) {
      setState(() {
        _receivedData += String.fromCharCodes(data);
      });
    });

    setState(() {
      _connected = true;
    });
  }

  Future<void> _disconnect() async {
    await _bluetooth.disconnect();
    setState(() {
      _connected = false;
    });
  }

  Future<void> _sendData(String data) async {
    if (_connected) {
      await _bluetooth.write(data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não há conxexão"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conexão Bluetooth"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Dispositivos Pareados:",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: _pairedDevices.map((device) {
                return ListTile(
                  title: Text(device.name ?? "Desconhecido"),
                  subtitle: Text(device.address),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getPairedDevices,
              icon: const Icon(Icons.refresh),
              label: const Text("Atualizar Dispositivos Pareados"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Dispositivos Encontrados:",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _scanning ? const Text("Escaneando...") : const SizedBox(),
            Column(
              children: _discoveredDevices.map((device) {
                return ListTile(
                  title: Text(device.name ?? "Desconhecido"),
                  subtitle: Text(device.address),
                  onTap: () => _connectToDevice(device),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_scanning) {
                  _stopScan();
                } else {
                  _startScan();
                }
              },
              child: Text(
                  _scanning ? "Parar Escaneamento" : "Iniciar Escaneamento"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Status da Conexão:",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(_connected ? "Conectado" : "Desconectado"),
            ElevatedButton(
              onPressed: _connected ? _disconnect : null,
              child: const Text("Desconectar"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Dados Recebidos:",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(_receivedData),
            const SizedBox(height: 10),
            TextFormField(
              controller: sendDataController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    _sendData(sendDataController.text);
                  },
                  icon: const Icon(Icons.send),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelText: "Enviar dados",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
