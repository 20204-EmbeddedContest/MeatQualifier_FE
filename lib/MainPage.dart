import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import './BackgroundCollectedPage.dart';
import './BackgroundCollectingTask.dart';
import './ChatPage.dart';
import './SelectBondedDevicePage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BackgroundCollectingTask? _collectingTask;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BBQ ZONE'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Connect to paired device to chat'),
                    onPressed: () async {
                      final BluetoothDevice? selectedDevice = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SelectBondedDevicePage(checkAvailability: false);
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        print('Connect -> selected ' + selectedDevice.address);
                        _startChat(context, selectedDevice);
                      } else {
                        print('Connect -> no device selected');
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Icon(_collectingTask?.inProgress ?? false ? Icons.bluetooth_disabled : Icons.bluetooth),
                    onPressed: () async {
                      if (_collectingTask?.inProgress ?? false) {
                        await _collectingTask!.cancel();
                        setState(() {
                          _collectingTask = null; // Update for `_collectingTask.inProgress`
                        });
                      } else {
                        final BluetoothDevice? selectedDevice = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SelectBondedDevicePage(checkAvailability: false);
                            },
                          ),
                        );

                        if (selectedDevice != null) {
                          await _startBackgroundTask(context, selectedDevice);
                          setState(() {
                            // Update for `_collectingTask.inProgress`
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('View background collected data'),
                onPressed: (_collectingTask != null)
                    ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ScopedModel<BackgroundCollectingTask>(
                          model: _collectingTask!,
                          child: BackgroundCollectedPage(),
                        );
                      },
                    ),
                  );
                }
                    : null,
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _buildStyledCard(
                    'assets/images/sirloin.jpeg',
                    'Sirloin (牛)',
                    '국내산',
                    '2024.07.24',
                    '100',
                  ),
                  _buildStyledCard(
                    'assets/images/tenderloin.jpeg',
                    'Tenderloin (牛)',
                    '국내산',
                    '2024.07.24',
                    '100',
                  ),
                  _buildStyledCard(
                    'assets/images/tongue.jpeg',
                    'Tongue (牛)',
                    '국내산',
                    '2024.07.24',
                    '100',
                  ),
                  _buildStyledCard(
                    'assets/images/striploin.jpeg',
                    'Striploin (牛)',
                    '국내산',
                    '2024.07.24',
                    '100',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

  Future<void> _startBackgroundTask(
      BuildContext context,
      BluetoothDevice server,
      ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      print('Connected to background task');
      await _collectingTask!.start();
      print('Background task started');
    } catch (ex) {
      print('Error during background task: $ex');
      _collectingTask?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occurred while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
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

  Widget _buildStyledCard(
      String imagePath, String title, String origin, String purchaseDate, String quantity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 160, // 원하는 크기로 조정 가능
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // 전체 모서리를 둥글게
          border: Border.all(
            color: Colors.grey.shade300, // 테두리 색상
            width: 1, // 테두리 두께
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // 그림자 위치
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // 상단 모서리 둥글게
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 140,  // 이미지 높이
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    '생산지: $origin',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '구입일: $purchaseDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '정수: $quantity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12), // 마지막 텍스트와 아래 간격
          ],
        ),
      ),
    );
  }
}
