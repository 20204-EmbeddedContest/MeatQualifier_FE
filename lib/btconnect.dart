import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothConnect extends StatefulWidget {
  @override
  _BluetoothConnectState createState() => _BluetoothConnectState();
}

class _BluetoothConnectState extends State<BluetoothConnect> {
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print("Error getting bonded devices: $e");
    }
    setState(() {
      _devicesList = devices;
    });
  }

  void _onDeviceSelected(BluetoothDevice device) {
    setState(() {
      _selectedDevice = device;
      _isConnecting = false;
    });
    Navigator.pop(context); // Close the device selection popup
  }

  void _showDeviceSelection() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('사용 가능한 디바이스'),
          content: _devicesList.isEmpty
              ? Text('연결 가능한 디바이스가 없습니다.')
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _devicesList
                  .map((device) => ListTile(
                title: Text(device.name ?? "Unknown"),
                onTap: () => _onDeviceSelected(device),
              ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showDeviceSelection,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bluetooth),
              SizedBox(width: 10),
              Text('연결하기'),
            ],
          ),
        ),
        if (_selectedDevice != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Text(
                  "Device: ${_selectedDevice!.name ?? "Unknown"}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Battery: 64%", // You can replace this with the actual battery status if available
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
