import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';

class BluetoothConnectionView extends StatefulWidget {
  const BluetoothConnectionView({Key? key}) : super(key: key);

  @override
  _BluetoothConnectionViewState createState() => _BluetoothConnectionViewState();
}

class _BluetoothConnectionViewState extends State<BluetoothConnectionView> {
  final BluetoothClassic _bluetooth = BluetoothClassic();
  List<Device> _pairedDevices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  bool _connected = false;
  String _receivedData = '';

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
    await _bluetooth.connect(device.address, "00001101-0000-1000-8000-00805f9b34fb");

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
    await _bluetooth.write(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conexão Bluetooth"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Dispositivos Pareados:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: _pairedDevices.map((device) {
                return ListTile(
                  title: Text(device.name ?? "Desconhecido"),
                  subtitle: Text(device.address),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getPairedDevices,
              icon: Icon(Icons.refresh),
              label: Text("Atualizar Dispositivos Pareados"),
            ),
            SizedBox(height: 20),
            Text(
              "Dispositivos Encontrados:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _scanning ? Text("Escaneando...") : SizedBox(),
            Column(
              children: _discoveredDevices.map((device) {
                return ListTile(
                  title: Text(device.name ?? "Desconhecido"),
                  subtitle: Text(device.address),
                  onTap: () => _connectToDevice(device),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_scanning) {
                  _stopScan();
                } else {
                  _startScan();
                }
              },
              child: Text(_scanning ? "Parar Escaneamento" : "Iniciar Escaneamento"),
            ),

            SizedBox(height: 20),
            Text(
              "Status da Conexão:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(_connected ? "Conectado" : "Desconectado"),
            ElevatedButton(
              onPressed: _connected ? _disconnect : null,
              child: Text("Desconectar"),
            ),
            SizedBox(height: 20),
            Text(
              "Dados Recebidos:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(_receivedData),
            ElevatedButton(
              onPressed: () => _sendData("ping"),
              child: Text("Enviar Dados"),
            ),
          ],
        ),
      ),
    );
  }
}
