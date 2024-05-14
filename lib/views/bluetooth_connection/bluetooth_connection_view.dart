import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothClassicScreen extends StatefulWidget {
  @override
  _BluetoothClassicScreenState createState() => _BluetoothClassicScreenState();
}

class _BluetoothClassicScreenState extends State<BluetoothClassicScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FlutterBluetoothSerial.instance.requestEnable(),
      builder: (context, future) {
        if (future.connectionState == ConnectionState.waiting) {
          Center(
            child: CircularProgressIndicator(),
          );
        } else if (future.connectionState == ConnectionState.done) {
          return Home();
        }
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Connection"),
        ),
        body: SelectedBondedDevicePage(
          onCahtPage: (device1) {
            BluetoothDevice device = device1;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ChatPage(server: device);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class SelectedBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;
  final Function onCahtPage;

  const SelectedBondedDevicePage({super.key, this.checkAvailability = true, required this.onCahtPage,});

  @override
  State<SelectedBondedDevicePage> createState() => _SelectedBondedDevicePageState();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _SelectedBondedDevicePageState extends State<SelectedBondedDevicePage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();

  // availability
  StreamSubscription<>

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

