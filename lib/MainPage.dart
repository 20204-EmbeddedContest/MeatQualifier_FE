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
  bool _showExpandedBox = false; // 흰색 박스 확장 상태
  BluetoothDevice? _connectedDevice; // 현재 연결된 디바이스
  String _deviceName = '연결되지 않음'; // 기본 상태 텍스트

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
    final double paddingSize = 37.8; // 10mm in pixels
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Bottom half (white background)
          Positioned.fill(
            bottom: screenHeight / 2,
            child: Container(
              color: Colors.white,
            ),
          ),
          // Top half (gradient background)
          Positioned.fill(
            top: screenHeight / 2,
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
                              child: Text(_deviceName),
                              onPressed: () async {
                                setState(() {
                                  _showExpandedBox = true; // 박스 열기
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: ElevatedButton(
                          child: Text('View background collected data'),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 흰색 박스
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _showExpandedBox ? screenHeight / 2 : 200,
              padding: EdgeInsets.symmetric(horizontal: paddingSize, vertical: 20), // 좌우 여백 및 아래 여백
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 그림자 색상
                    spreadRadius: 3, // 그림자 크기 조절
                    blurRadius: 6, // 흐림 정도 조절
                    offset: Offset(0, -2), // 그림자의 위치 조절
                  ),
                ],
              ),
              child: _showExpandedBox
                  ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '연결가능한 기기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: _buildBluetoothDeviceList()),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_connectedDevice == null) // 연결된 디바이스가 없을 때만 표시
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showExpandedBox = true; // 박스 열기
                        });
                        // 블루투스 연결 로직을 여기에 추가
                      },
                      child: Text('연결되지 않음'),
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
                  SizedBox(height: 20),
                  if (_connectedDevice != null) // 연결된 디바이스가 있을 때만 표시
                    Row(
                      children: [
                        Icon(
                          Icons.bluetooth,
                          size: 30, // 아이콘 크기 설정
                          color: Colors.blue,
                        ),
                        SizedBox(width: 16), // 아이콘과 텍스트 사이의 간격
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽으로 정렬
                          children: [
                            Text(
                              '${_connectedDevice!.name ?? 'Unknown Device'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4), // 디바이스명과 배터리 상태 사이의 간격
                            Text(
                              '배터리: 64%',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothDeviceList() {
    return FutureBuilder<List<BluetoothDevice>>(
      future: FlutterBluetoothSerial.instance.getBondedDevices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No paired devices found'));
        } else {
          final devices = snapshot.data!;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(
                  device.name ?? 'Unknown Device',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: SizedBox.shrink(), // 주소 숨기기
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _handleConnectButtonPressed(device);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bluetooth,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                      Text('연결하기'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 버튼 배경색 흰색
                    foregroundColor: Colors.black, // 버튼 텍스트 색상 검정색
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // 버튼 크기 조절
                    side: BorderSide(color: Colors.black), // 검정 테두리
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _handleConnectButtonPressed(BluetoothDevice device) async {
    try {
      await _startBackgroundTask(context, device);
      setState(() {
        _showExpandedBox = false; // 박스 닫기
        _deviceName = device.name ?? '연결된 디바이스'; // 연결된 디바이스명 업데이트
        _connectedDevice = device; // 연결된 디바이스 저장
      });
    } catch (ex) {
      print('Error during background task: $ex');
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

  Future<void> _startBackgroundTask(BuildContext context, BluetoothDevice server) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      print('Connected to background task');
      await _collectingTask!.start();
      print('Background task started');
    } catch (ex) {
      print('Error during background task: $ex');
      _collectingTask?.cancel();
      rethrow;
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
              builder: (context) => AddPage(),
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
