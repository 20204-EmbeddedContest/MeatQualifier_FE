import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import './BackgroundCollectedPage.dart';
import './BackgroundCollectingTask.dart';
import './ChatPage.dart';
import './SelectBondedDevicePage.dart';
import './addpage.dart';

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
      body: Stack(
        children: [
          // Bottom half (white background)
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height / 2,
            child: Container(
              color: Colors.white,
            ),
          ),
          // Top half (gradient background)
          Positioned.fill(
            top: MediaQuery.of(context).size.height / 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.withOpacity(0.5), Colors.white],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              AppBar(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '너의 고기는',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_none_sharp),
                      onPressed: () {
                        // Implement notification action here
                      },
                    ),
                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
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
                              '등심 (牛)',
                              '국내산',
                              '2024.07.24',
                              '100',
                            ),
                            _buildStyledCard(
                              'assets/images/tenderloin.jpeg',
                              '안심 (牛)',
                              '국내산',
                              '2024.07.24',
                              '100',
                            ),
                            _buildStyledCard(
                              'assets/images/tongue.jpeg',
                              '우설 (牛)',
                              '국내산',
                              '2024.07.24',
                              '100',
                            ),
                            _buildStyledCard(
                              'assets/images/striploin.jpeg',
                              '채끝살 (牛)',
                              '국내산',
                              '2024.07.24',
                              '100',
                            ),
                            _buildMoreCard(), // 더보기 카드 추가
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Padding container for space above the white box
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0), // Add space below the button
                        child: Container(
                          width: double.infinity,
                          height: 200, // Adjust height if needed
                          padding: EdgeInsets.symmetric(horizontal: 40.0), // 좌우 여백
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1), // 그림자 색상
                                  spreadRadius: 3, // 그림자 크기 조절
                                  blurRadius: 6, // 흐림 정도 조절
                                  offset: Offset(0, 4), // 그림자의 위치 조절
                                ),
                              ],
                            ),
                            child: Center(
                              child: ElevatedButton(
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bluetooth, color: Colors.black),
                                    SizedBox(width: 10),
                                    Text('연결하기'),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // 버튼 배경색 흰색
                                  foregroundColor: Colors.black, // 버튼 텍스트 색상 검정색
                                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0), // 버튼 크기 조절
                                  side: BorderSide(color: Colors.black), // 검정 테두리
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildStyledCard(String imagePath, String title, String origin, String purchaseDate, String quantity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('생산지', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(origin, style: TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('구입일', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(purchaseDate, style: TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('점수', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text(quantity, style: TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPage(), // AddPage로 네비게이션
            ),
          );
        },
        child: Container(
          width: 160,
          height: 258,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_sharp,
                size: 60,
                color: Colors.red.shade600,
              ),
              SizedBox(height: 10),
              Text(
                '더보기',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
