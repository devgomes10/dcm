import 'dart:convert';
import 'package:dcm/views/components/menu_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ELM327 OBD2 Bluetooth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MenuNavigator(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isConnected = false;
  final _commandController = TextEditingController();
  String _output = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (allGranted) {
      _initBluetooth();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Algumas permissões não são concedidas."),
        ),
      );
    }
  }

  void _initBluetooth() {
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _getPairedDevices();
  }

  void _getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao obter dispositivos vinculados"),
        ),
      );
    }
    setState(() {
      _devicesList = devices;
    });
  }

  void _connect() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhum dispositivo vinculado"),
        ),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      _connection =
          await BluetoothConnection.toAddress(_selectedDevice!.address);
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      _connection!.input!.listen((Uint8List data) {
        _onDataReceived(data);
      }).onDone(() {
        setState(() {
          _isConnected = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não pode ser conectado"),
        ),
      );
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _onDataReceived(Uint8List data) {
    setState(() {
      _output += '${utf8.decode(data)}\n';
    });
  }

  void _sendCommand(String command) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(utf8.encode("$command\r\n")));
      await _connection!.output.allSent;
    }
  }

  void _clearOutput() {
    setState(() {
      _output = '';
    });
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Resposta copiada para a área de transferência."),
      ),
    );
  }

  @override
  void dispose() {
    _commandController.dispose();
    _connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner MWM'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<BluetoothDevice>(
                    items: _devicesList.map((device) {
                      return DropdownMenuItem(
                        value: device,
                        child: Text(device.name ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDevice = value;
                      });
                    },
                    value: _selectedDevice,
                    hint: const Text('Selecionar o dispositivo'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isConnecting ? null : _connect,
                  child: Text(_isConnecting ? 'Conectando...' : 'Conectado'),
                ),
              ],
            ),
            Text('Bluetooth Status: $_bluetoothState'),
            TextFormField(
              controller: _commandController,
              decoration: const InputDecoration(labelText: 'Comando'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _isConnected
                      ? () => _sendCommand(_commandController.text)
                      : null,
                  child: const Text('Enviar Comando'),
                ),
                ElevatedButton(
                  onPressed: _clearOutput,
                  child: const Text("Limpar tela"),
                ),
                ElevatedButton(
                  onPressed: _copyOutput,
                  child: const Text("Copiar"),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_output),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
