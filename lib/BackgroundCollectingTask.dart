import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

class DataSample {
  double temperature1;
  double temperature2;
  double waterpHlevel;
  DateTime timestamp;

  DataSample({
    required this.temperature1,
    required this.temperature2,
    required this.waterpHlevel,
    required this.timestamp,
  });
}

class BackgroundCollectingTask extends Model {
  static BackgroundCollectingTask of(
      BuildContext context, {
        bool rebuildOnChange = false,
      }) =>
      ScopedModel.of<BackgroundCollectingTask>(
        context,
        rebuildOnChange: rebuildOnChange,
      );

  final BluetoothConnection _connection;
  List<int> _buffer = List<int>.empty(growable: true);
  List<DataSample> samples = List<DataSample>.empty(growable: true);
  bool inProgress = false;

  BackgroundCollectingTask._fromConnection(this._connection) {
    _connection.input!.listen((data) {
      _buffer += data;

      while (true) {
        // '\n'을 찾아서 데이터의 끝을 확인
        int index = _buffer.indexOf('\n'.codeUnitAt(0));
        if (index >= 0) {
          // 데이터 문자열을 파싱
          String dataString = utf8.decode(_buffer.sublist(0, index));
          _buffer.removeRange(0, index + 1);

          if (dataString.startsWith('t')) {
            List<String> parts = dataString.substring(1).split(',');
            if (parts.length == 3) {
              try {
                double temperature1 = double.parse(parts[0]);
                double temperature2 = double.parse(parts[1]);
                double waterpHlevel = double.parse(parts[2]);
                final DataSample sample = DataSample(
                  temperature1: temperature1,
                  temperature2: temperature2,
                  waterpHlevel: waterpHlevel,
                  timestamp: DateTime.now(),
                );

                samples.add(sample);
                notifyListeners();
              } catch (e) {
                print('Error parsing data: $e');
              }
            }
          }
        } else {
          break;
        }
      }
    }).onDone(() {
      inProgress = false;
      notifyListeners();
    });
  }

  static Future<BackgroundCollectingTask> connect(BluetoothDevice server) async {
    final BluetoothConnection connection = await BluetoothConnection.toAddress(server.address);
    return BackgroundCollectingTask._fromConnection(connection);
  }

  void dispose() {
    _connection.dispose();
  }

  Future<void> start() async {
    inProgress = true;
    _buffer.clear();
    samples.clear();
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Future<void> cancel() async {
    inProgress = false;
    notifyListeners();
    _connection.output.add(ascii.encode('stop'));
    await _connection.finish();
  }

  Future<void> pause() async {
    inProgress = false;
    notifyListeners();
    _connection.output.add(ascii.encode('stop'));
    await _connection.output.allSent;
  }

  Future<void> resume() async {
    inProgress = true;
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Iterable<DataSample> getLastOf(Duration duration) {
    DateTime startingTime = DateTime.now().subtract(duration);
    int i = samples.length;
    do {
      i -= 1;
      if (i <= 0) {
        break;
      }
    } while (samples[i].timestamp.isAfter(startingTime));
    return samples.getRange(i, samples.length);
  }
}
