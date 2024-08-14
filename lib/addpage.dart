import 'package:flutter/material.dart';

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 페이지'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '새로운 흰색 페이지',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
