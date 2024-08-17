import 'package:flutter/material.dart';
import 'detailpage.dart'; // 추가된 detailpage.dart 파일을 임포트

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<Map<String, dynamic>> items = [
    {
      'name': '등심(牛)',
      'date': '2024.07.24',
      'weight': '600g',
      'imagePath': 'assets/images/sirloin.jpeg',
      'origin': '국내산',
      'storageMethod': '냉동',
      'freshnessData': [100, 89, 73],
    },
    {
      'name': '등심(牛)2',
      'date': '2024.07.26',
      'weight': '600g',
      'imagePath': 'assets/images/sirloin.jpeg',
      'origin': '국내산',
      'storageMethod': '냉동',
      'freshnessData': [1, 10, 100],
    },
    {
      'name': '등심(牛)3',
      'date': '2024.01.24',
      'weight': '600g',
      'imagePath': 'assets/images/sirloin.jpeg',
      'origin': '국내산',
      'storageMethod': '냉동',
      'freshnessData': [100, 0, 73],
    },
    {
      'name': '등심(牛)4',
      'date': '2024.03.24',
      'weight': '600g',
      'imagePath': 'assets/images/sirloin.jpeg',
      'origin': '국내산',
      'storageMethod': '냉동',
      'freshnessData': [100, 89, 0],
    },
    // 추가 항목도 같은 형식으로 작성할 수 있습니다.
  ];

  String _selectedSortOption = '구매 날짜 순 ↑'; // 기본 정렬 옵션
  int? _selectedIndex; // 선택된 아이템의 인덱스를 저장

  void _sortItems() {
    setState(() {
      if (_selectedSortOption == '구매 날짜 순 ↑') {
        items.sort((a, b) {
          DateTime dateA = _parseDate(a['date']);
          DateTime dateB = _parseDate(b['date']);
          return dateA.compareTo(dateB);
        });
      } else if (_selectedSortOption == '구매 날짜 순 ↓') {
        items.sort((a, b) {
          DateTime dateA = _parseDate(a['date']);
          DateTime dateB = _parseDate(b['date']);
          return dateB.compareTo(dateA);
        });
      }

      // 디버깅용으로 정렬된 날짜 출력
      for (var item in items) {
        print(item['date']);
      }
    });
  }

  DateTime _parseDate(String date) {
    // 날짜 형식을 제대로 파싱
    List<String> parts = date.split('.');
    return DateTime(
      int.parse(parts[0]), // 연도
      int.parse(parts[1]), // 월
      int.parse(parts[2]), // 일
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('너의 고기는'),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: _selectedSortOption,
                icon: Icon(Icons.sort, color: Colors.white), // 정렬 아이콘
                dropdownColor: Colors.white, // 드롭다운 배경색
                underline: Container(), // 밑줄을 없애기 위해 빈 Container 사용
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSortOption = newValue!;
                    _sortItems(); // 정렬 함수 호출
                  });
                },
                items: <String>[
                  '구매 날짜 순 ↑',
                  '구매 날짜 순 ↓',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 14), // 드롭다운 메뉴의 텍스트 스타일
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index; // 현재 아이템이 선택된 상태인지 확인

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onDoubleTap: () {
                if (_selectedIndex == index) {
                  // 더블 탭 시 선택된 아이템이면 화면 전환
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        imagePath: items[index]['imagePath'],
                        name: items[index]['name'],
                        origin: items[index]['origin'],
                        purchaseDate: items[index]['date'],
                        storageMethod: items[index]['storageMethod'],
                        freshnessData:
                            List<int>.from(items[index]['freshnessData']),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : null, // 선택된 상태라면 배경색 적용
                  borderRadius: isSelected
                      ? BorderRadius.circular(12)
                      : null, // 선택된 상태라면 둥근 모서리 적용
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : [], // 선택된 상태라면 그림자 적용
                ),
                child: ListTile(
                  leading: Image.asset(
                    items[index]['imagePath'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    items[index]['name'],
                    style: TextStyle(
                      fontWeight: _selectedIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                      '${items[index]['date']} • ${items[index]['weight']}'),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index; // 선택된 아이템 강조
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
