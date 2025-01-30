import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isConnected = false;
  final _commandController = TextEditingController();
  String _output = '';

  List<String> _commands = [
    'AT SP A',
    'AT CAF 0',
    'AT AL',
    'AT CRA 0CF00400',
    '18FEF100',
    '18FEF200',
    '18FEF300',
  ];

  int _currentCommandIndex = 0;
  Timer? _commandTimer;

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

      _sendNextCommand();

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

  void _sendNextCommand() async {
    if (_currentCommandIndex < _commands.length) {
      String command = _commands[_currentCommandIndex];
      _sendCommand(command);
      _currentCommandIndex++;
      _commandTimer = Timer(Duration(milliseconds: 500), _sendNextCommand);
    } else {
      _currentCommandIndex = 0; // Reset index to send commands again
    }
  }

  void _sendCommand(String command) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(utf8.encode("$command\r\n")));
      await _connection!.output.allSent;
    }
  }

  void _onDataReceived(Uint8List data) {
    String dataString = utf8.decode(data);
    setState(() {
      _output += '$dataString\n';
    });

    if (_commandTimer != null && _commandTimer!.isActive) {
      _commandTimer!.cancel(); // Cancel the timer if we received data
      _sendNextCommand(); // Send the next command immediately
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
        title: const Text("Ajustes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
