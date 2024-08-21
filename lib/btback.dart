import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

class BluetoothConnectionPage extends StatefulWidget {
  @override
  _BluetoothConnectionPageState createState() => _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    final state = await FlutterBluetoothSerial.instance.state;
    setState(() {
      _bluetoothState = state;
    });

    if (_bluetoothState == BluetoothState.STATE_ON) {
      _devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {});
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      if (_connection != null) {
        await _connection!.close();
        setState(() {
          _connection = null;
        });
      }

      final connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _selectedDevice = device;
      });

      connection.input!.listen((data) {
        print('Data incoming: ${utf8.decode(data)}');
      }).onDone(() {
        print('Connection closed.');
        setState(() {
          _connection = null;
        });
      });

      connection.output.add(Uint8List.fromList(utf8.encode("Hello from Flutter!")));
      print('Data sent to ${device.name}');

    } catch (e) {
      print('Connection error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Connection Error'),
          content: Text('Failed to connect: $e'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Connection'),
      ),
      body: _bluetoothState != BluetoothState.STATE_ON
          ? Center(child: Text('Bluetooth is off'))
          : ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (context, index) {
          final device = _devicesList[index];
          return ListTile(
            title: Text(device.name ?? 'Unknown Device'),
            trailing: ElevatedButton(
              onPressed: () async {
                await _connectToDevice(device);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth),
                  SizedBox(width: 8),
                  Text('Connect'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
