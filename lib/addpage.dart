import 'package:flutter/material.dart';
import 'detailpage.dart';  // 추가된 detailpage.dart 파일을 임포트

class AddPage extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      'name': '등심(牛)',
      'date': '2024.07.24',
      'weight': '600g',
      'imagePath': 'assets/images/sirloin.jpeg',
      'origin': '국내산',
      'storageMethod': '냉동',
      'freshnessData': [100, 89, 73],
    },
    // 추가 항목도 같은 형식으로 작성할 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('너의 고기는'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(
              items[index]['imagePath'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(
              items[index]['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${items[index]['date']} • ${items[index]['weight']}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    imagePath: items[index]['imagePath'],
                    name: items[index]['name'],
                    origin: items[index]['origin'],
                    purchaseDate: items[index]['date'],
                    storageMethod: items[index]['storageMethod'],
                    freshnessData: List<int>.from(items[index]['freshnessData']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
